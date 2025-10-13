#from django.shortcuts import render

# Create your views here.

from django.forms.models import model_to_dict

from django.contrib.auth.hashers import check_password   

# IMPORT APP CLASS
from account.models import Userian
from product.models import Product

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from account.serializers import UserianSerializer
from product.serializers import ProductSerializer

@api_view(["GET", "POST"])
def api_home(request, *args, **kwargs):
    if request.method == "GET":
        qs = Userian.objects.values("id","username","email")[:10]
        return Response({"users": list(qs)})

    return Response({"received": request.data}, status=status.HTTP_201_CREATED)    


@api_view(["POST"])
def register_user(request, *args, **kwargs):
    """
    POST /api/register/
    Expect JSON with fields by UserianSerializer (e.g. name, username, password, email, phoneNum, role).
    """

    serializer = UserianSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({"user": serializer.data}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
def login_user(request, *args, **kwargs):
    """
    POST /api/login/
    Body: { "username": "...","password":"..."}
    Will returns 200 + basic user info on success, 401 on failure
    """

    username = (request.data.get("username") or "").strip()
    password = request.data.get("password") or ""

    if not username or not password:
        return Response({"detail": "Username and password required"}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = Userian.objects.get(username=username)
    except Userian.DoesNotExist:
        return Response({"detail": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

    if check_password(password, user.password):
        data = {"id": user.id, "username": user.username, "name": user.name, "email": user.email, "role": user.role}
        return Response({"user": data}, status=status.HTTP_200_OK)

    return Response({"detail": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
    
