from django.shortcuts import render
from rest_framework import viewsets, permissions
from .serializers import UserianSerializer
from .models import Userian

# Create your views here.

class UserianViewSet(viewsets.ModelViewSet):
    queryset = Userian.objects.all()
    serializer_class = UserianSerializer
    permission_classes = [permissions.AllowAny] # NEED TO CHANGE ISAUTHENTICATED LATER