from rest_framework import serializers
from .models import Userian
from django.contrib.auth.hashers import make_password

class UserianSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userian
        fields = ['name','username', 'password', 'role','email', 'phoneNum']
        extra_kwargs = {'password' : {'write_only': True}}

    def create(self, validated_data):
        # HASH THE PASSWORD BEFORE SAVING

        pwd = validated_data.pop('password', None)
        if pwd:
            validated_data['password'] = make_password(pwd)
        return super().create(validated_data)