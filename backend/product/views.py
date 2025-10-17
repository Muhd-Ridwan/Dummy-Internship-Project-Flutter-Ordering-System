from decimal import Decimal
from django.db import transaction
from rest_framework.decorators import api_view, permission_classes
from rest_framework import permissions, status
from rest_framework.response import Response

from .serializers import ProductSerializer, OrderSerializer
from rest_framework import viewsets, permissions


from .models import Product, Order

# Create your views here.


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by('id')
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]  # NEED TO CHANGE ISAUTHENTICATED LATER


class OrderViewSet(viewsets.ModelViewSet):
    """
    List user's orders (authenticated) or all order is staff
    """
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        user = self.request.user
        if getattr(user, "is_staff", False):
            return Order.objects.all().order_by('-created_at')
        if user and user.is_authenticated:
            return Order.objects.filter(buyer=user).order_by('-created_at')
        return Order.objects.none()


@api_view(['POST'])
@permission_classes([permissions.AllowAny])  # Change to IsAuthenticated if you want only logged-in users to purchase
def purchase_product(request, pk):
    """
    POST /api/products/pk/purchase/
    body: {"quantity": int}
    """
    shipping_address = (request.data.get('shipping_address') or "").strip()
    shipping_method  = (request.data.get('shipping_method')  or "").strip()

    # NEW: resolve Userian
    # also allow clients to pass user_id explicitly as a fallback
    fallback_user_id = request.data.get("user_id")
    buyer = resolve_userian_from_request(request, fallback_user_id=fallback_user_id)

    if buyer is None:
        return Response({"detail": "Unable to resolve buyer profile."}, status=status.HTTP_400_BAD_REQUEST)

    with transaction.atomic():
        product = Product.objects.select_for_update().get(pk=pk)
        if product.stock < qty:
            return Response({"detail": "Insufficient stock."}, status=status.HTTP_400_BAD_REQUEST)

        product.stock -= qty
        product.save(update_fields=["stock"])

        order = Order.objects.create(
            product=product,
            buyer=buyer,  # <-- now a real account.Userian
            quantity=qty,
            total_price=product.price * qty,
            shipping_address=shipping_address,
            shipping_method=shipping_method,
            status=Order.STATUS_PENDING,
        )

    return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)