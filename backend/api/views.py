#from django.shortcuts import render

# Create your views here.

from django.forms.models import model_to_dict

# IMPORT APP CLASS
from account.models import Userian

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(["GET", "POST"])
def api_home(request, *args, **kwargs):
    if request.method == "GET":
        qs = Userian.objects.values("id","username","email")[:10]
        return Response({"users": list(qs)})

    return Response({"received": request.data}, status=status.HTTP_201_CREATED)    
