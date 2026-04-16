from rest_framework import serializers
from .models import Group, SharedExpense, ExpenseSplit

class ExpenseSplitSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseSplit
        fields = '__all__'

class SharedExpenseSerializer(serializers.ModelSerializer):
    splits = ExpenseSplitSerializer(many=True, read_only=True)
    class Meta:
        model = SharedExpense
        fields = '__all__'
        read_only_fields = ('group',)

class GroupSerializer(serializers.ModelSerializer):
    expenses = SharedExpenseSerializer(many=True, read_only=True)
    balances = serializers.SerializerMethodField()

    class Meta:
        model = Group
        fields = ['id', 'name', 'created_by', 'members', 'created_at', 'expenses', 'balances']
        read_only_fields = ['created_by']

    def get_balances(self, obj):
        balances = []
        for member in obj.members.all():
            owed = sum(s.amount_owed for s in ExpenseSplit.objects.filter(user=member, shared_expense__group=obj, is_settled=False))
            paid = sum(e.amount for e in SharedExpense.objects.filter(paid_by=member, group=obj))
            net = float(paid) - float(owed)
            balances.append({
                'member_id': member.id,
                'member_name': member.username,
                'owed': owed,
                'paid': paid,
                'net': net
            })
        return balances
