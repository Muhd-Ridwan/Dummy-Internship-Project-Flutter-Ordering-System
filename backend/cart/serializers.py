from rest_framework import serializers
from .models import Cart, CartItem, Order, OrderItem
from decimal import Decimal

class CartItemSerializer(serializers.ModelSerializer):
    line_total = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ['id', 'product_id', 'name', 'price', 'quantity', 'added_at', 'line_total']
    
    def get_line_total(self, obj):
        return str(obj.price * obj.quantity)

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many = True, read_only=True)
    subtotal = serializers.SerializerMethodField()
    total = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = ['id', 'user', 'created_at', 'items', 'subtotal', 'total']

    def get_total(self, obj: Cart):
        total = Decimal('0')
        for it in obj.items.all():
            total += (it.price * it.quantity)
        return str(total)
    
    def get_total(self, obj: Cart):
        return self.get_subtotal(obj)
    

# FOR ORDERS
class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = [
            'product_id',
            'name',
            'unit_price',
            'quantity',
            'line_total',
        ]

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            'id',
            'user',
            'name',
            'phone',
            'address',
            'payment_method',
            'shipping_method',
            'delivery_fee',
            'subtotal',
            'total',
            'status',
            'created_at',
            'items',
        ]