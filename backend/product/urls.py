from rest_framework.routers import DefaultRouter
from .views import ProductViewSet, purchase_product, OrderViewSet
from django.urls import path

router = DefaultRouter()
router.register(r'', ProductViewSet, basename = 'product')
router.register(r'orders', OrderViewSet, basename='order')

urlpatterns = router.urls

urlpatterns += [
    path('<int:pk>/purchase/', purchase_product, name='purchase_product'),
]