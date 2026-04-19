from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    monthly_budget = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    profile_picture = models.ImageField(upload_to='profiles/', blank=True, null=True)
    
    assets = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    loans = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    
    is_2fa_enabled = models.BooleanField(default=False)

    def __str__(self):
        return self.username

class LoginActivity(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='login_history')
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.CharField(max_length=255, null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} logged in at {self.timestamp}"
