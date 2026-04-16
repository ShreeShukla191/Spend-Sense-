from django.contrib import admin
from .models import Goal

@admin.register(Goal)
class GoalAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'target_amount', 'saved_amount', 'deadline', 'progress_percentage')
    list_filter = ('deadline',)
