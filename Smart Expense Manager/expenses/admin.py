from django.contrib import admin
from .models import Expense

@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ('description', 'user', 'amount', 'date', 'category', 'payment_mode', 'mood')
    list_filter = ('date', 'category', 'payment_mode', 'mood')
    search_fields = ('description', 'user__username')
