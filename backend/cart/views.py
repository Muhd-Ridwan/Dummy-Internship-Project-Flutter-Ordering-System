from django.shortcuts import render
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from .models import Cart, CartItem
from .serializers import CartSerializer, CartItemSerializer
from account.models import Userian

# Create your views here.

@api_view(["GET"])
def get_cart(request):
    # EXPECTING USER_ID = OR (ONCE AUTH) USER REQUEST.USER
    user_id = request.query_params.get('user_id')
    if not user_id:
        return Response({"error": "user_id query parameter is required."}, status=status.HTTP_400_BAD_REQUEST)
    try:
        user = Userian.objects.get(pk=user_id)
    except Userian.DoesNotExist:
        return Response({"detail": "user_id not found."}, status=status.HTTP_404_NOT_FOUND)
    cart, _ = Cart.objects.get_or_create(user=user)
    serializer = CartSerializer(cart)
    return Response(serializer.data)

@api_view(["POST"])
def add_to_cart(request):
    """
    POST /API/CART/ADD
    payload: {user_id, product_id, name, price, quantity}
    """

    data = request.data
    user_id = data.get('user_id')
    try:
        user = Userian.objects.get(pk=user_id)
    except:
        return Response({"detail":"invalid user"}, status=status.HTTP_400_BAD_REQUEST)
    
    cart, _ = Cart.objects.get_or_create(user=user)
    # TRY TO FIND EXISTING ITEM BY PRODUCT ID

    prod_id = data.get('product_id')
    qty = int(data.get('quantity', 1))

    try:
        item = cart.items.get(product_id=prod_id)
        item.quantity += qty
        item.save()
    except CartItem.DoesNotExist:
        item = CartItem.objects.create(
            cart=cart,
            product_id=prod_id,
            name=data.get('name', ''),
            price=data.get('price', 0),
            quantity=qty
        )
    return Response(CartItemSerializer(item).data, status=status.HTTP_201_CREATED)

@api_view(["PUT", "DELETE"])
def cart_item_detail(request, pk):
    """
    PUT /api/cart/item/<pk> with {"quantity": new_qty}
    DELETE /api/cart/item/<pk>
    """

    try:
        item = CartItem.objects.get(pk=pk)
    except CartItem.DoesNotExist:
        return Response({"detail":"item not found"}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == "PUT":
        qty = int(request.data.get('quantity', item.quantity))
        if qty<= 0:
            item.delete()
            return Response({"detail":"deleted"}, status=status.HTTP_204_NO_CONTENT)
        
        item.quantity = qty
        item.save()
        return Response(CartItemSerializer(item).data)
    

    # DELETE
    item.delete()
    return Response({"detail":"deleted"}, status=status.HTTP_204_NO_CONTENT)

@api_view(["POST"])
def checkout(request):
    """
    POST /api/cart/checkout with {user_id}
    Implement the fake payment here. Cause this is not production ready.
    """

    user_id = request.data.get('user_id')
    try:
        user = Userian.objects.get(pk=user_id)
    except:
        return Response({"detail":"invalid user"}, status=status.HTTP_400_BAD_REQUEST)
    
    cart, _ = Cart.objects.get_or_create(user=user)
    # WILL CREATE ORDER HERE, CHRAGE PAYMENT, REDUCE STOCK
    serializer = CartSerializer(cart)
    # CLEARING CART ITEMS
    cart.items.all().delete()
    return Response({"status":"ok", "cart": serializer.data})