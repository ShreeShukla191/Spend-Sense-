from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.views.decorators.csrf import csrf_exempt
from . import views

urlpatterns = [
    path('register/', csrf_exempt(views.RegisterAPIView.as_view()), name='api-register'),
    path('login/', csrf_exempt(views.CustomTokenObtainPairView.as_view()), name='api-login'),
    path('token/refresh/', csrf_exempt(TokenRefreshView.as_view()), name='api-token-refresh'),
    path('settings/', views.UserSettingsAPIView.as_view(), name='api-settings'),
    path('login-activity/', views.LoginActivityAPIView.as_view(), name='api-login-activity'),
]
