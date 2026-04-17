from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Group, SharedExpense, ExpenseSplit
from .serializers import GroupSerializer, SharedExpenseSerializer

class GroupViewSet(viewsets.ModelViewSet):
    serializer_class = GroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.request.user.split_groups.all()

    def perform_create(self, serializer):
        group = serializer.save(created_by=self.request.user)
        group.members.add(self.request.user)

    @action(detail=True, methods=['post'])
    def add_member(self, request, pk=None):
        from django.contrib.auth import get_user_model
        from django.db.models import Q
        User = get_user_model()
        
        group = self.get_object()
        identifier = request.data.get('username')
        
        if not identifier:
            return Response({'error': 'Please provide an email or username'}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            user = User.objects.get(Q(username=identifier) | Q(email=identifier))
            group.members.add(user)
            return Response({'status': 'added', 'member_id': user.id, 'member_name': user.username})
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['post'])
    def add_shared_expense(self, request, pk=None):
        group = self.get_object()
        serializer = SharedExpenseSerializer(data=request.data)
        if serializer.is_valid():
            expense = serializer.save(group=group)
            
            members = group.members.all()
            if members.count() > 0:
                split_amount = expense.amount / members.count()
                
                for member in members:
                    ExpenseSplit.objects.create(
                        shared_expense=expense,
                        user=member,
                        amount_owed=split_amount,
                        is_settled=(member == expense.paid_by)
                    )
            return Response(SharedExpenseSerializer(expense).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
