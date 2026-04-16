from django.db import models
from django.conf import settings

class Goal(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='goals')
    name = models.CharField(max_length=100)
    target_amount = models.DecimalField(max_digits=10, decimal_places=2)
    saved_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    deadline = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    STATUS_CHOICES = [
        ('Active', 'Active'),
        ('Paused', 'Paused'),
        ('Reached', 'Reached')
    ]
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Active')

    @property
    def progress_percentage(self):
        if self.target_amount > 0:
            return min(100, int((self.saved_amount / self.target_amount) * 100))
        return 0

    def __str__(self):
        return f"{self.name} - {self.progress_percentage}%"
