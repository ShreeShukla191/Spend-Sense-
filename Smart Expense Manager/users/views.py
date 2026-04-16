from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .serializers import UserRegistrationSerializer, UserSerializer

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

        return Response({"error": "Invalid action"}, status=status.HTTP_400_BAD_REQUEST)
