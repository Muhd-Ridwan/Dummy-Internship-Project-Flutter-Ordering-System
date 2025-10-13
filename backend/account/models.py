from django.db import models

# Create your models here.

class Userian(models.Model):
    name = models.CharField(max_length = 100)
    username = models.CharField(max_length = 100)
    password = models.CharField(max_length = 100)
    role = models.CharField(max_length = 50)
    email = models.CharField(max_length = 50)
    phoneNum = models.CharField(max_length = 20)

    def __str__(self):
        return str({self.name} - {self.username} - {self.role})

    # def generateRandomStuff():
    #     import random
    #     import string
    #     characters = string.ascii_letters + string.digits + string.punctuation
    #     random_string = ''.join(random.choice(characters) for i in range(50))
    #     return random_string