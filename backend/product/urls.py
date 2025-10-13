from rest_framework.routers import DefaultRouter
from .views import ProductViewSet, purchase_product
from django.urls import path

router = DefaultRouter()
router.register(r'', ProductViewSet, basename = 'product')

urlpatterns = router.urls

urlpatterns += [
    path('products/<int:pk>/purchase/', purchase_product, name='purchase_product'),
]