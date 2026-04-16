from django.db import models
from django.conf import settings

class Group(models.Model):
    name = models.CharField(max_length=100)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='created_groups')
    members = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='split_groups')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class SharedExpense(models.Model):
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='expenses')
    title = models.CharField(max_length=200)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    paid_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='paid_expenses')
    date = models.DateField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - ₹{self.amount}"

class ExpenseSplit(models.Model):
    shared_expense = models.ForeignKey(SharedExpense, on_delete=models.CASCADE, related_name='splits')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    amount_owed = models.DecimalField(max_digits=10, decimal_places=2)
    is_settled = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.username} owes ₹{self.amount_owed} for {self.shared_expense.title}"
