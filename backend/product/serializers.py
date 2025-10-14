from rest_framework import serializers
from .models import Product, Order

class ProductSerializer(serializers.ModelSerializer):
# ENSURING SERIALIZER USES URL FOR IMAGE
    image = serializers.ImageField(use_url=True, required=False, allow_null=True)

    class Meta:
        model = Product
        # fields = ['name', 'description', 'price', 'stock', 'brand', 'category']
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    class Meta:
        model = Order
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'total_price', 'buyer'] 