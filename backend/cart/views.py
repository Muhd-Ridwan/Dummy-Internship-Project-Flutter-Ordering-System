from typing import Optional
from django.db import transaction
from decimal import Decimal
from product.models import Product, Order
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from account.models import Userian
from product.models import Product, Order
from product.serializers import OrderSerializer
from .models import Cart, CartItem
from .serializers import CartSerializer, CartItemSerializer
from account.utils import resolve_userian_from_request

# Create your views here.

def resolve_userian_from_request(request, fallback_user_id: Optional[int] = None) -> Optional[Userian]:
    """
    Map JWT-authenticated Django `User` back to `account.Userian`.
    Tries email first, then username like 'cust_<id>'.
    """
    u = getattr(request, "user", None)
    if u and u.is_authenticated:
        cust = Userian.objects.filter(email=u.email).first()
        if not cust and u.username.startswith("cust_"):
            try:
                cid = int(u.username.split("_", 1)[1])
                cust = Userian.objects.filter(id=cid).first()
            except Exception:
                cust = None
        if cust:
            return cust

    # fallback (for legacy add_to_cart that sends user_id)
    if fallback_user_id:
        try:
            return Userian.objects.get(pk=int(fallback_user_id))
        except (Userian.DoesNotExist, ValueError, TypeError):
            return None

    return None



@api_view(["GET"])
@permission_classes([IsAuthenticated])  # recommended
def get_cart(request):
    """
    GET /api/cart/?user_id=<id>   (user_id optional if JWT is present)
    """
    # try JWT first; fall back to ?user_id=
    user_id = request.query_params.get('user_id')
    cust = resolve_userian_from_request(request, fallback_user_id=int(user_id) if user_id else None)
    if not cust:
        return Response({"detail": "Unable to resolve user"}, status=status.HTTP_400_BAD_REQUEST)

    cart, _ = Cart.objects.get_or_create(user=cust)
    serializer = CartSerializer(cart)
    return Response(serializer.data)


# @api_view(["GET"])
# def get_cart(request):
#     # EXPECTING USER_ID = OR (ONCE AUTH) USER REQUEST.USER
#     user_id = request.query_params.get('user_id')
#     cust = resolve_userian_from_request(request, fallback_user_id=int(user_id) if user_id else None)

#     if not cust:
#         return Response({"error": "user_id query parameter is required."}, status=status.HTTP_400_BAD_REQUEST)
#     try:
#         user = Userian.objects.get(pk=user_id)
#     except Userian.DoesNotExist:
#         return Response({"detail": "user_id not found."}, status=status.HTTP_404_NOT_FOUND)
    
#     cart, _ = Cart.objects.get_or_create(user=user)
#     serializer = CartSerializer(cart)
#     return Response(serializer.data)

@api_view(["POST"])
@permission_classes([IsAuthenticated])  
def add_to_cart(request):
    """
    POST /api/cart/add/
    Body: { product_id, name, price, quantity, user_id? }
    If JWT is present, user_id is optional.
    """
    data = request.data
    user_id = data.get("user_id")

    user = resolve_userian_from_request(request, fallback_user_id=user_id)
    if not user:
        return Response({"detail": "invalid user"}, status=status.HTTP_400_BAD_REQUEST)

    cart, _ = Cart.objects.get_or_create(user=user)

    try:
        prod_id = int(data.get("product_id"))
        qty = int(data.get("quantity", 1))
        if qty <= 0:
            return Response({"detail": "quantity must be > 0"}, status=400)
    except (TypeError, ValueError):
        return Response({"detail": "invalid product_id/quantity"}, status=400)

    name = (data.get("name") or "").strip()
    # be safe with DecimalField
    try:
        price = Decimal(str(data.get("price", "0")))
    except Exception:
        price = Decimal("0")

    try:
        item = cart.items.get(product_id=prod_id)
        item.quantity += qty
        item.save()
    except CartItem.DoesNotExist:
        item = CartItem.objects.create(
            cart=cart,
            product_id=prod_id,
            name=name,
            price=price,
            quantity=qty,
        )

    return Response(CartItemSerializer(item).data, status=status.HTTP_201_CREATED)



@api_view(["PUT", "DELETE"])
@permission_classes([IsAuthenticated])  
def cart_item_detail(request, pk):
    """
    PUT /api/cart/item/<pk> with {"quantity": new_qty}
    DELETE /api/cart/item/<pk>
    """
    try:
        item = CartItem.objects.get(pk=pk)
    except CartItem.DoesNotExist:
        return Response({"detail": "item not found"}, status=status.HTTP_404_NOT_FOUND)

    if request.method == "PUT":
        try:
            qty = int(request.data.get('quantity', item.quantity))
        except (TypeError, ValueError):
            return Response({"detail": "quantity must be int"}, status=status.HTTP_400_BAD_REQUEST)

        if qty <= 0:
            item.delete()
            return Response({"detail": "deleted"}, status=status.HTTP_204_NO_CONTENT)

        item.quantity = qty
        item.save(update_fields=["quantity"])
        return Response(CartItemSerializer(item).data)

    # DELETE
    item.delete()
    return Response({"detail": "deleted"}, status=status.HTTP_204_NO_CONTENT)



@api_view(["POST"])
@permission_classes([IsAuthenticated])  
def checkout(request):
    """
    POST /api/cart/checkout/
    Body: { user_id? }
    Uses JWT to resolve user; falls back to user_id if provided.
    """
    fallback_user_id = request.data.get('user_id')
    cust = resolve_userian_from_request(request, fallback_user_id=fallback_user_id)
    if not cust:
        return Response({"detail": "Unable to resolve user"}, status=status.HTTP_400_BAD_REQUEST)

    cart, _ = Cart.objects.get_or_create(user=cust)

    # TODO: here is where you'd:
    # - create Order rows from cart.items
    # - deduct Product stock (use select_for_update)
    # - charge payment
    # For now, we keep your previous "clear cart" behavior.

    data_before_clear = CartSerializer(cart).data  # optional: snapshot before clearing
    cart.items.all().delete()

    return Response({"status": "ok", "cart": data_before_clear})


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def checkout_enhanced(request):
    """
    POST /api/cart/checkout-enhanced/
    Body:
    {
      "items": [
        {"product_id": 1, "name": "X", "unit_price": 12.34, "quantity": 2},
        ...
      ],
      "payment_method": "FPX Online Banking" | "Credit/Debit Card",
      "shipping_method": "self" | "2days",
      "address": "string",
      "phone": "string",
      "delivery_fee": 2.0 | 5.0
    }
    Returns: { order_id(s), status, subtotal, delivery_fee, total }
    """
    cust = resolve_userian_from_request(request)
    if not cust:
        return Response({"detail": "Not authenticated"}, status=status.HTTP_401_UNAUTHORIZED)

    data = request.data
    items = data.get("items") or []
    shipping_method = data.get("shipping_method") or "self"
    address = (data.get("address") or "").strip()
    phone = (data.get("phone") or "").strip()
    delivery_fee = float(data.get("delivery_fee") or 0)

    if not items:
        return Response({"detail": "No items to checkout."}, status=status.HTTP_400_BAD_REQUEST)
    if not address:
        return Response({"detail": "Address is required."}, status=status.HTTP_400_BAD_REQUEST)

    # calculate subtotal first (server-side trust but verify)
    subtotal = 0.0
    for it in items:
        qty = int(it.get("quantity") or 0)
        unit = float(it.get("unit_price") or 0)
        if qty <= 0 or unit < 0:
            return Response({"detail": "Invalid item payload."}, status=status.HTTP_400_BAD_REQUEST)
        subtotal += qty * unit
    total = subtotal + delivery_fee

    created_orders = []

    # Deduct stock + create orders atomically per item
    with transaction.atomic():
        for it in items:
            pid = int(it.get("product_id") or 0)
            qty = int(it.get("quantity") or 0)

            # lock row
            try:
                product = Product.objects.select_for_update().get(pk=pid)
            except Product.DoesNotExist:
                return Response({"detail": f"Product {pid} not found."}, status=status.HTTP_404_NOT_FOUND)

            if product.stock < qty:
                return Response({"detail": f"Insufficient stock for {product.name}."}, status=status.HTTP_400_BAD_REQUEST)

            product.stock -= qty
            product.save(update_fields=["stock"])

            order = Order.objects.create(
                product=product,
                buyer=cust,
                quantity=qty,
                total_price=product.price * qty,
                shipping_address=address,
                shipping_method="Self Collection" if shipping_method == "self" else "2-Days Delivery",
                status=Order.STATUS_SHIPPED,  # as per your requirement
            )
            created_orders.append(order.id)

        # clear the cart after success (optional)
        cart, _ = Cart.objects.get_or_create(user=cust)
        cart.items.all().delete()

    return Response({
        "status": "ok",
        "orders": created_orders,
        "subtotal": float(subtotal),
        "delivery_fee": float(delivery_fee),
        "total": float(total),
    }, status=status.HTTP_201_CREATED)

