#from django.shortcuts import render

# Create your views here.

from django.forms.models import model_to_dict

from django.contrib.auth.hashers import check_password   

# IMPORT APP CLASS
from account.models import Userian
from product.models import Product
from account.serializers import UserianSerializer, UserianProfileSerializer
from product.serializers import ProductSerializer

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


# IMPORTING
from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny

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

def _ensure_django_user(cust: Userian) -> User:
    username = f"cust_{cust.id}"
    user, _ = User.objects.get_or_create(
        username=username,
        defaults={"email": cust.email or "", "is_active": True},
    )

    # KEEPING EMAIL IN SYNC
    if user.email != (cust.email or ""):
        user.email = cust.email or ""
        user.save(update_fields=["email"])
    return user

@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request, *args, **kwargs):
    serializer = UserianSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({"user" : serializer.data}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request, *args, **kwargs):
    """
    POST /api/login/
    Body: { "username": "...", "password":"..."}
    Returns: {access, refresh, user: {id, email, username, role}}
    """

    username = (request.data.get("username") or "").strip()
    password = request.data.get("password") or ""

    if not username or not password:
        return Response({"detail": "Username and password required"}, status=400)
    
    try:
        cust = Userian.objects.get(username=username)
    except Userian.DoesNotExist:
        return Response({"detail":"Invalid Credentials"}, status=401)

    # CHECKING HASHED PASSWORD
    if not check_password(password, cust.password):
        return Response({"detail":"Invalid Credentials"}, status=401)

    
    # ISSUE JWT BY TYIONG CUSTOMER TO A DJANGO
    user = _ensure_django_user(cust)
    refresh = RefreshToken.for_user(user)
    access = refresh.access_token

    # FOR DEBUGGING PURPOSES
    access["role"] = getattr(cust, "role", "customer")
    access["customer_id"] = cust.id

    return Response({
        "access": str(access),
        "refresh": str(refresh),
        "user":{
            "id":cust.id,
            "username": cust.username,
            "role":getattr(cust, "role", "customer"),
        }
    }, status=200)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me(request, *args, **kwargs):
    """
    GET /api/me/
    Returns current customer's profile inferred from JWT user.
    """

    # TRY BY EMAIL
    cust = Userian.objects.filter(email=request.user.email).first()

    # FALLBACK
    if not cust and request.user.username.startswith("cust_"):
        try:
            cid = int (request.user.username.split("_", 1)[1])
            cust = Userian.objects.filter(id=cid).first()
        except Exception:
            pass

    if not cust:
        return Response({"detail": "Profile not found"}, status=404)

    return Response({
        "id": cust.id,
        "email": cust.email,
        "username": cust.username,
        "role": getattr(cust, "role", "customer"),
    }, status=200)


# FOR EDITING PROFILE API CALLED
@api_view(["GET", "PATCH"])
@permission_classes([IsAuthenticated])
def my_profile(request, *args, **kwargs):
    """
    GET /api/profile/ -> full profile path to read & edit editable fields
    PATCH /api/profile/ -> updating phoneNum, address only
    """
    # TRY BY EMAIL ?
    cust = Userian.objects.filter(email=request.user.email).first()

    # FALLBACK
    if not cust and request.user.username.startsWith("cust_"):
        try:
            cid = int(request.user.username.split("_", 1)[1])
            cust = Userian.objects.filter(id=cid).first()
        except Exception:
            pass
            
    if not cust:
        return Response({"detail": "Profile not found"}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == "GET":
        return Response(UserianProfileSerializer(cust).data)
    
    # PATCH
    ser = UserianProfileSerializer(cust, data=request.data, partial=True)
    ser.is_valid(raise_exception=True)
    ser.save()
    return Response(ser.data, status=status.HTTP_200_OK)
