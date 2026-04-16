from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    monthly_budget = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    profile_picture = models.ImageField(upload_to='profiles/', blank=True, null=True)
    
    assets = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    loans = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    
    def __str__(self):
        return self.username
