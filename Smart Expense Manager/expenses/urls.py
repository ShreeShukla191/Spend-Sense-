from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

app_name = 'expenses'

router = DefaultRouter()
router.register(r'category', views.CategoryViewSet, basename='category')
router.register(r'expense', views.ExpenseViewSet, basename='expense')
router.register(r'income', views.IncomeViewSet, basename='income')
router.register(r'subscription', views.SubscriptionViewSet, basename='subscription')
router.register(r'account', views.AccountViewSet, basename='account')
router.register(r'dividend', views.DividendViewSet, basename='dividend')
router.register(r'fee', views.FeeViewSet, basename='fee')

urlpatterns = [
    path('api/categories/', views.category_api, name='api-categories'),
    path('', include(router.urls)),
]
