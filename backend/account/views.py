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
from django.conf import settings
from django.contrib.auth.tokens import default_token_generator as token_generator
from django.core.mail import send_mail
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
from django.urls import reverse
from django.contrib.auth.hashers import make_password




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
    cust = Userian.objects.filter(email=request.user.email).first()
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



@api_view(['POST'])
@permission_classes([AllowAny])
def password_forgot(request):
    """
    POST /api/password/forgot/
    body: {"username": "<username>"}
    Always returns 200 (don’t leak whether user exists).
    """
    username = (request.data.get("username") or "").strip()

    # Try to find your custom user
    cust = Userian.objects.filter(username=username).first()
    if not cust:
        return Response({"sent": True})  # same response for non-existing usernames

    # Ensure there is a Django auth user for token generation
    user = _django_user(cust)

    uidb64 = urlsafe_base64_encode(force_bytes(user.pk))
    token = token_generator.make_token(user)

    reset_url = request.build_absolute_uri(
        reverse('password_reset_confirm_api', args=[uidb64, token])
    )

    # Send via console backend in dev; configure real SMTP in production
    send_mail(
        subject='Reset your password',
        message=f'Click the link to reset your password: {reset_url}',
        from_email=getattr(settings, "DEFAULT_FROM_EMAIL", "no-reply@example.com"),
        recipient_list=[cust.email],
        fail_silently=True,
    )

    return Response({"sent": True}, status=200)


@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def password_reset_confirm(request, uidb64, token):
    """
    GET  -> validate token (returns {"valid": true/false})
    POST -> body: {"password": "<new password>"} to set a new password
    """
    try:
        uid = urlsafe_base64_decode(uidb64).decode()
        user = User.objects.get(pk=uid)
    except Exception:
        return Response({"valid": False}, status=status.HTTP_400_BAD_REQUEST)

    if not token_generator.check_token(user, token):
        return Response({"valid": False}, status=status.HTTP_400_BAD_REQUEST)

    if request.method == "GET":
        return Response({"valid": True})

    # POST: set new password
    new_pwd = (request.data.get("password") or "").strip()
    if not new_pwd:
        return Response({"detail": "password is required"}, status=400)

    user.set_password(new_pwd)
    user.save(update_fields=["password"])

    # Keep your custom table in sync (optional but likely needed in your app)
    cust = Userian.objects.filter(email=user.email).first()
    if cust:
        cust.password = make_password(new_pwd)
        cust.save(update_fields=["password"])

    return Response({"ok": True}, status=200)
