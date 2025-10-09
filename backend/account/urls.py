from rest_framework.routers import DefaultRouter
from .views import UserianViewSet

router = DefaultRouter()
router.register(r'users', UserianViewSet, basename = 'userian')


urlpatterns = router.urls