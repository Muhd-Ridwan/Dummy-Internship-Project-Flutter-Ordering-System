from django.shortcuts import render
from .models import Product
from .serializers import ProductSerializer
from rest_framework import viewsets, permissions
from django.db import transaction
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status


from .models import Product, Order
from .serializers import OrderSerializer

# Create your views here.


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]  # NEED TO CHANGE ISAUTHENTICATED LATER


@api_view(['POST'])
@permission_classes([AllowAny])  # Change to IsAuthenticated if needed
def purchase_product(request, pk):
    """
    POST /api/products/pk/purchase/
    body: {"quantity": int}
    """
    try:
        qty = int(request.data.get('quantity', 1))
    except (TypeError, ValueError):
        return Response({"detail": "quantity must be an integer."}, status=status.HTTP_400_BAD_REQUEST)
    if qty <= 0:
        return Response({"detail": "quantity must be > 0."}, status=status.HTTP_400_BAD_REQUEST)
    
    with transaction.atomic():
        try:
            product = Product.objects.select_for_update().get(pk=pk)
        except Product.DoesNotExist:
            return Response({"detail": "Product not found."}, status=status.HTTP_404_NOT_FOUND)
        if product.stock < qty:
            return Response({"detail": "Insufficient stock."}, status=status.HTTP_400_BAD_REQUEST)
        
        product.stock -= qty
        product.save()

        buyer = request.user if getattr(request, "user", None) and request.user.is_authenticated else None

        order = Order.objects.create(
            product=product,
            buyer=buyer,
            quantity=qty,
            total_price=qty * product.price
        )
    
    return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)