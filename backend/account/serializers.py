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

        pwd = validated_data.get('password')
        if pwd:
            validated_data['password'] = make_password(pwd)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        pwd = validated_data.pop('password', None)
        if pwd:
            instance.password = make_password(pwd)
        return super().update(instance, validated_data)
    
    def validate_username(self, value):
        qs = Userian.objects.filter(username=value)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            raise serializers.ValidationError("This username is already taken.")
        return value

class UserianProfileSerializer(serializers.ModelSerializer):
    """
    Used by /api/profile/
    Only 'phoneNum' and 'address' are editable; other fields are read-only.
    """

    class Meta:
        model = Userian
        fields = ["id", "name", "username", "email", "role", "phoneNum", "address"]
        read_only_fields = ["id", "name", "username", "email", "role"]