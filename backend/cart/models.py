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

    def subtotal(self):
        return self.price * self.quantity
    
    def __str__(self):
        return f'{self.name} x {self.quantity} ({self.cart.user.username})'
