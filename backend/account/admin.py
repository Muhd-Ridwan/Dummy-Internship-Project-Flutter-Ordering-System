from django.contrib import admin
from .models import Userian


# Register your models here.

# admin.site.register(Userian)

@admin.register(Userian)
class UserianAdmin(admin.ModelAdmin):
    list_display = ('id', 'username', 'email', 'role')
    search_fields = ('username', 'email')