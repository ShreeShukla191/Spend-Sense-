from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .serializers import UserRegistrationSerializer, UserSerializer, LoginActivitySerializer
from .models import LoginActivity
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import OutstandingToken, BlacklistedToken

class RegisterAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({"message": f"Account created for {user.username}"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserSettingsAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def post(self, request):
        action = request.data.get('action')
        user = request.user

        if action == 'update_profile':
            user.first_name = request.data.get('first_name', user.first_name)
            user.last_name = request.data.get('last_name', user.last_name)
            user.email = request.data.get('email', user.email)
            user.save()
            return Response({"message": "Profile updated successfully"})
        
        elif action == 'update_budget':
            try:
                user.monthly_budget = float(request.data.get('monthly_budget', user.monthly_budget))
                user.save()
                return Response({"message": "Monthly budget updated successfully"})
            except ValueError:
                return Response({"error": "Invalid budget amount."}, status=status.HTTP_400_BAD_REQUEST)
        
        elif action == 'update_ai':
            request.session['ai_enabled'] = request.data.get('ai_enabled', True)
            request.session['ai_sensitivity'] = request.data.get('ai_sensitivity', 'medium')
            return Response({"message": "AI Preferences updated successfully"})

        elif action == 'change_password':
            old_password = request.data.get('old_password')
            new_password = request.data.get('new_password')
            if not user.check_password(old_password):
                return Response({"error": "Incorrect old password"}, status=status.HTTP_400_BAD_REQUEST)
            user.set_password(new_password)
            user.save()
            return Response({"message": "Password updated successfully"})

        elif action == 'toggle_2fa':
            user.is_2fa_enabled = request.data.get('is_2fa_enabled', False)
            user.save()
            return Response({"message": "2FA settings updated"})

        elif action == 'logout_all':
            tokens = OutstandingToken.objects.filter(user=user)
            for token in tokens:
                BlacklistedToken.objects.get_or_create(token=token)
            return Response({"message": "Logged out from all devices"})

        return Response({"error": "Invalid action"}, status=status.HTTP_400_BAD_REQUEST)

class CustomTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            try:
                from rest_framework_simplejwt.tokens import AccessToken
                from django.contrib.auth import get_user_model
                User = get_user_model()
                token = AccessToken(response.data.get('access'))
                user_id = token['user_id']
                user = User.objects.get(id=user_id)
                
                # Get IP and user agent
                x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
                if x_forwarded_for:
                    ip = x_forwarded_for.split(',')[0]
                else:
                    ip = request.META.get('REMOTE_ADDR')
                user_agent = request.META.get('HTTP_USER_AGENT', '')
                LoginActivity.objects.create(user=user, ip_address=ip, user_agent=user_agent)
            except Exception as e:
                print(f"Error logging activity: {e}")
        return response

class LoginActivityAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        activities = LoginActivity.objects.filter(user=request.user).order_by('-timestamp')[:10]
        serializer = LoginActivitySerializer(activities, many=True)
        return Response(serializer.data)
