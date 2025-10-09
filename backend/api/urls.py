from django.urls import path
from .views import api_home
#from rest_framework.routers import DefaultRouter
# from items.views import ItemViewSet # EXAMPLE RESOURCES
# from accounts.views import MyTokenObtainPairView
# from rest_framework_simplejwt.views import TokenRefreshView

# router = DefaultRouter()
# router.register(r'items', ItemViewSet, basename = 'items')

urlpatterns = [
    path('', api_home, name="api_home"), # /api/accounts/users/
]