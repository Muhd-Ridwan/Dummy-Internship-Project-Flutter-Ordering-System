from django.shortcuts import render
from rest_framework import viewsets, permissions
from .serializers import UserianSerializer
from .models import Userian
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes


# Create your views here.

class UserianViewSet(viewsets.ModelViewSet):
    queryset = Userian.objects.all()
    serializer_class = UserianSerializer
    permission_classes = [permissions.AllowAny] # NEED TO CHANGE ISAUTHENTICATED LATER


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({"Ok": True, "user": request.user.username})