from django.db import models

# Create your models here.

class Product(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField()
    brand = models.CharField(max_length=100)
    category = models.CharField(max_length=100)

    def __str__(self):
        return ({'name': self.name, 'description': self.description, 'price': str(self.price), 'stock': self.stock, 'brand': self.brand, 'category': self.category})