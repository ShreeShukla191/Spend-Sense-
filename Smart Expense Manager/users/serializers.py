from rest_framework import serializers
from .models import User
from django.contrib.auth.password_validation import validate_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'monthly_budget', 'profile_picture', 'assets', 'loans')
        read_only_fields = ('id', 'username')

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'password_confirm', 'monthly_budget', 'assets', 'loans')

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs

    def create(self, validated_data):
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            monthly_budget=validated_data.get('monthly_budget', 0.00),
            assets=validated_data.get('assets', 0.00),
            loans=validated_data.get('loans', 0.00),
        )
        user.set_password(validated_data['password'])
        user.save()
        return user
