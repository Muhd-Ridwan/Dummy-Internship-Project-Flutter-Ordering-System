from rest_framework import serializers
from .models import Userian

class UserianSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userian
        fields = ['name','username', 'password', 'role','email', 'phoneNum']