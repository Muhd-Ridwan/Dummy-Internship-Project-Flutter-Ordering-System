#from django.shortcuts import render

# Create your views here.

from django.forms.models import model_to_dict

# IMPORT APP CLASS
from account.models import Userian

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from account.serializers import UserianSerializer

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
    
