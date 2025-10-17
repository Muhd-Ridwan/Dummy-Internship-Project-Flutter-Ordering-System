from django.urls import path
from .views import api_home, register_user, login_user, me, my_profile # IMPORT EVERY DEF THAT CREATE IN VIEWS.PY FROM THE APPLICATION
from cart import views as cart_views


#from rest_framework.routers import DefaultRouter
# from items.views import ItemViewSet # EXAMPLE RESOURCES
# from accounts.views import MyTokenObtainPairView
# from rest_framework_simplejwt.views import TokenRefreshView

# router = DefaultRouter()
# router.register(r'items', ItemViewSet, basename = 'items')

urlpatterns = [
    path('', api_home, name="api_home"), # /api/accounts/users/
    path('register/', register_user, name='api_register'), # /api/accounts/register
    path('login/', login_user, name='api_login'), # /api/accounts/login
    path('me/', me, name='api_me'), # /api/accounts/me
    # CART ENDPONT
    path('cart/', cart_views.get_cart, name='api_cart'), # /api/cart/?user_id=1
    path('cart/add/', cart_views.add_to_cart, name='api_cart_add'),
    path('cart/item/<int:pk>/', cart_views.cart_item_detail, name='api_cart_item_detail'), # /api/cart/item/1/
    path('cart/checkout/', cart_views.checkout, name='api_cart_checkout'), # /api/cart/checkout/
    path('profile/', my_profile, name='api_profile'),
    path('cart/checkout-enhanced/', cart_views.checkout_enhanced, name='api_cart_checkout_enhanced'), # /api/cart/checkout-enhanced/
]