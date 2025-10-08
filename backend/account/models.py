from django.db import models

# Create your models here.

class Userian(models.Model):
    username = models.CharField(max_length = 100)
    password = models.CharField(max_length = 100)
    role = models.CharField(max_length = 50)
    email = models.CharField(max_length = 50)