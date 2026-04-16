from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from . import views

urlpatterns = [
    path('register/', views.RegisterAPIView.as_view(), name='api-register'),
    path('login/', TokenObtainPairView.as_view(), name='api-login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='api-token-refresh'),
    path('settings/', views.UserSettingsAPIView.as_view(), name='api-settings'),
]
