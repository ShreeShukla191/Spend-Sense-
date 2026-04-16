from django.contrib import admin
from .models import Group, SharedExpense, ExpenseSplit

@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_by', 'created_at')

@admin.register(SharedExpense)
class SharedExpenseAdmin(admin.ModelAdmin):
    list_display = ('title', 'group', 'amount', 'paid_by', 'date')

@admin.register(ExpenseSplit)
class ExpenseSplitAdmin(admin.ModelAdmin):
    list_display = ('shared_expense', 'user', 'amount_owed', 'is_settled')
    list_filter = ('is_settled', 'user')
