from decimal import Decimal
from itertools import product
from django.db import transaction
from rest_framework.decorators import api_view, permission_classes
from rest_framework import permissions, status
from rest_framework.response import Response
from account.models import Userian

from .serializers import ProductSerializer, OrderSerializer
from rest_framework import viewsets, permissions


from .models import Product, Order

# Create your views here.

def resolve_userian_from_request(request, fallback_user_id: int | None = None) -> Userian | None:
    user = getattr(request, "user", None)
    if user and user.is_authenticated:
        # Try by email
        if user.email:
            u = Userian.objects.filter(email=user.email).first()
            if u:
                return u
        # Try username like 'cust_<id>'
        if user.username and user.username.startswith("cust_"):
            try:
                cid = int(user.username.split("_", 1)[1])
                u = Userian.objects.filter(id=cid).first()
                if u:
                    return u
            except Exception:
                pass
    # Fallback explicit id (optional)
    if fallback_user_id:
        return Userian.objects.filter(id=fallback_user_id).first()
    return None



class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by('id')
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]  # NEED TO CHANGE ISAUTHENTICATED LATER
    lookup_value_regex = r'\d+'


class OrderViewSet(viewsets.ModelViewSet):
    """
    List user's orders (authenticated) or all order is staff
    """
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if getattr(user, "is_staff", False):
            return Order.objects.all().order_by('-created_at')

        cust = resolve_userian_from_request(self.request)
        if not cust:
            return Order.objects.none()
        return Order.objects.filter(buyer=cust).order_by('-created_at')


@api_view(['POST'])
@permission_classes([permissions.AllowAny])  # Change to IsAuthenticated if you want only logged-in users to purchase
def purchase_product(request, pk):
    """
    POST /api/products/pk/purchase/
    body: {"quantity": int}
    """
    try:
        qty = int(request.data.get('quantity', 1))
    except (TypeError, ValueError):
        return Response({"detail":"quantity must be an integer."}, status = status.HTTP_400_BAD_REQUEST)
    if qty <= 0:
        return Response({"detail":"quantity must be more than 0"}, status = status.HTTP_400_BAD_REQUEST)

    shipping_address = (request.data.get('shipping_address') or "").strip()
    shipping_method  = (request.data.get('shipping_method')  or "").strip()

    # NEW: resolve Userian
    # also allow clients to pass user_id explicitly as a fallback
    fallback_user_id = request.data.get("user_id")
    buyer = resolve_userian_from_request(request, fallback_user_id=fallback_user_id)

    if buyer is None:
        return Response({"detail": "Unable to resolve buyer profile."}, status=status.HTTP_400_BAD_REQUEST)
    

    with transaction.atomic():
        try:
            product = Product.objects.select_for_update().get(pk=pk)
        except Product.DoesNotExist:
            return Response({"detail": "Product not found."}, status=status.HTTP_404_NOT_FOUND)

        if product.stock < qty:
            return Response({"detail": "Insufficient stock."}, status=status.HTTP_400_BAD_REQUEST)

        product.stock -= qty
        product.save(update_fields=["stock"])

        order = Order.objects.create(
            product=product,
            buyer=buyer,                         # NEW: must be Userian
            quantity=qty,
            total_price=product.price * qty,     # Decimal * int is fine
            shipping_address=shipping_address,
            shipping_method=shipping_method,
            status=Order.STATUS_PENDING,
        )

        # product = Product.objects.select_for_update().get(pk=pk)
        # if product.stock < qty:
        #     return Response({"detail": "Insufficient stock."}, status=status.HTTP_400_BAD_REQUEST)

        # product.stock -= qty
        # product.save(update_fields=["stock"])

        # order = Order.objects.create(
        #     product=product,
        #     buyer=buyer,  # <-- now a real account.Userian
        #     quantity=qty,
        #     total_price=product.price * qty,
        #     shipping_address=shipping_address,
        #     shipping_method=shipping_method,
        #     status=Order.STATUS_PENDING,
        # )

    return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)