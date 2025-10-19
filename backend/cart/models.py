from django.db import models
from account.models import Userian
from django.utils import timezone

# Create your models here.

class Cart(models.Model):
    user = models.OneToOneField(Userian, on_delete=models.CASCADE, related_name='cart')
    created_at = models.DateTimeField(default=timezone.now)

    # DETERMINE WHICH ONE WANT TO BE THE RETURN VALUE
    def __str__(self):
        return f"Cart of {self.user.username}"
    
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='items')
    product_id = models.IntegerField()
    name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField(default=1)
    added_at = models.DateTimeField(default=timezone.now)

    def line_total(self):
        return self.price * self.quantity
    
    def __str__(self):
        return f'{self.name} x {self.quantity} ({self.cart.user.username})'
    

class Order(models.Model):
    STATUS_CHOICES = [
        ("pending", "Pending"),
        ("paid", "Paid"),
        ("shipped", "Shipped"),
        ("delivered", "Delivered"),
        ("cancelled", "Cancelled"),
    ]

    user = models.ForeignKey(Userian, on_delete=models.CASCADE, related_name='orders')

    # SNAPSHOT OF CUSTOMER
    name = models.CharField(max_length=200, blank=True, default="")
    phone = models.CharField(max_length=50, blank=True, default="")
    address = models.TextField(blank=True, default="")

    payment_method = models.CharField(max_length=100, blank=True, default="")
    shipping_method = models.CharField(max_length=50, blank=True, default="")
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="shipped")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Order #{self.id} for {self.user.username} ({self.status})'
    

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product_id = models.IntegerField()
    name = models.CharField(max_length=200)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField()
    line_total = models.DecimalField(max_digits=12, decimal_places=2)

    def __str__(self):
        return f'{self.name} x {self.quantity} (Order #{self.order.id})'