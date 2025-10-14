from django.db import models

# Create your models here.

class Product(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField()
    brand = models.CharField(max_length=100)
    category = models.CharField(max_length=100)

    # IMAGE
    image = models.ImageField(upload_to='products/', null=True, blank=True)

    def __str__(self):
        return str ({'name': self.name, 'description': self.description, 'price': str(self.price), 'stock': self.stock, 'brand': self.brand, 'category': self.category})
    

class Order(models.Model):
    STATUS_PENDING = 'PENDING'
    STATUS_SHIPPED = 'SHIPPED'
    STATUS_DELIVERED = 'DELIVERED'
    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_SHIPPED, 'Shipped'),
        (STATUS_DELIVERED, 'Delivered'),
    ]

    product = models.ForeignKey('Product', on_delete=models.CASCADE, related_name='orders')
    buyer = models.ForeignKey('account.Userian', on_delete=models.SET_NULL, null = True, blank = True)
    quantity = models.PositiveIntegerField()
    total_price = models.DecimalField(max_digits=12, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    # New shipping & status fields
    shipping_address = models.TextField(blank=True, null=True)
    shipping_method = models.CharField(max_length=100, blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_PENDING)

    def __str__(self):
        return f"Order #{self.id} - {self.product.name} x {self.quantity}"