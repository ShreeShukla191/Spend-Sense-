from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('users.urls')),
    path('expenses/', include('expenses.urls')),
    path('goals/', include('goals.urls')),
    path('split/', include('split.urls')),
    path('', include('analytics.urls')),
]
