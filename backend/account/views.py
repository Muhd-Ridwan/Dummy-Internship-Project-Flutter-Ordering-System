from rest_framework.decorators import api_view, permission_classes
from rest_framework import viewsets, permissions, status

from .serializers import UserianSerializer
from .models import Userian


from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from django.contrib.auth.models import User
from django.contrib.auth.hashers import check_password



# Create your views here.

def _django_user(cust: Userian) -> User:
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
def login(request):
    """
    POST /accounts/login (In future if want to change structure and wire this in urls.py)
    Body: { "username": "...","password":"..."}
    Returns: {access, refresh, user:{id, username, email, role}}
    """
    # LOCAL IMPORT
    from rest_framework.simplejwt.tokens import RefreshToken
    
    username = request.data.get("username")
    password = request.data.get("password")

    if not username or not password:
        return Response({"detail": "Missing Credentials"}, status=400)
    
    try:
        cust = Userian.objects.get(username=username)
    except Userian.DoesNotExist:
        return Response({"detail": "Invalid Credentials"}, status=status.HTTP_401_UNAUTHORIZED)

    if not check_password(password, cust.password):
        return Response({"detail": "Invalid Credentials"}, status=status.HTTP_401_UNAUTHORIZED)

    user = _django_user(cust)

    refresh = RefreshToken.for_user(user)
    access = refresh.access_token

    # OPTIONAL CODE BELOW FOR CUSTOM CLAIMS
    access["role"]= getattr(cust, "role", "customer")
    access["customer_id"] = cust.id

    return Response({
        "access": str(access),
        "refresh": str(refresh),
        "user" : {
            "id": cust.id,
            "username": cust.username,
            "email": cust.email,
            "role": getattr(cust, "role", "customer"),
        }
    }, status=200)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me(request):
    """
    GET /accounts/me (If want to change structure and wire this in urls.py)
    Resolve the current JWT user back to Userian record.
    """

    # TRY BY EMAIL
    cust = Userian.object.filter(email=request.user.email).first()
    if not cust and request.user.username.startswith("cust_"):
        try:
            cid = int(request.user.username.split("_", 1)[1])
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

# MODEL
class UserianViewSet(viewsets.ModelViewSet):
    queryset = Userian.objects.all()
    serializer_class = UserianSerializer
    permission_classes = [permissions.AllowAny] # NEED TO CHANGE ISAUTHENTICATED LATER


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({"Ok": True, "user": request.user.username})