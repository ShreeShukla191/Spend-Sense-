from rest_framework import viewsets, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.db.models import Q
from .models import Expense, Category, Income, Subscription, Account, Dividend, Fee
from .serializers import (
    ExpenseSerializer, CategorySerializer, IncomeSerializer,
    SubscriptionSerializer, AccountSerializer, DividendSerializer, FeeSerializer
)
from ml.category_predictor import predict_category as ml_predict_category

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def category_api(request):
    data = {}
    for c in Category.objects.all():
        if c.expense_type not in data: data[c.expense_type] = {}
        if c.main_category not in data[c.expense_type]: data[c.expense_type][c.main_category] = []
        data[c.expense_type][c.main_category].append({'id': c.id, 'name': c.sub_category, 'icon': c.icon})
    
    ai_suggestion = None
    query = request.GET.get('suggest')
    if query:
        str_val = ml_predict_category(query)
        match = Category.objects.filter(Q(sub_category__icontains=str_val) | Q(main_category__icontains=str_val)).first()
        if match:
            ai_suggestion = {'id': match.id, 'expense_type': match.expense_type, 'main_category': match.main_category, 'sub_category': match.sub_category, 'icon': match.icon}
            
    return Response({'hierarchy': data, 'suggestion': ai_suggestion})

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

class ExpenseViewSet(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = Expense.objects.filter(user=self.request.user)
        cat_filter = self.request.query_params.get('category')
        if cat_filter:
            qs = qs.filter(category__main_category=cat_filter)
        return qs

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class IncomeViewSet(viewsets.ModelViewSet):
    serializer_class = IncomeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Income.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class SubscriptionViewSet(viewsets.ModelViewSet):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Subscription.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class AccountViewSet(viewsets.ModelViewSet):
    serializer_class = AccountSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Account.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class DividendViewSet(viewsets.ModelViewSet):
    serializer_class = DividendSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Dividend.objects.filter(account__user=self.request.user)

class FeeViewSet(viewsets.ModelViewSet):
    serializer_class = FeeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Fee.objects.filter(account__user=self.request.user)
