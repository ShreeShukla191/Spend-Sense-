from rest_framework.decorators import api_view, permission_classes
from rest_framework import permissions
from rest_framework.response import Response
from django.http import HttpResponse, JsonResponse
from expenses.models import Expense, Income, Subscription, Account, Dividend, Fee
from split.models import ExpenseSplit, SharedExpense
from goals.models import Goal
from django.db.models import Sum
from ml.spending_predictor import predict_next_month_spending
from ml.clustering import get_financial_personality
from datetime import datetime
from dateutil.relativedelta import relativedelta
import csv
import json

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def dashboard(request):
    user = request.user
    expenses = Expense.objects.filter(user=user)
    
    selected_month = request.GET.get('month')
    selected_category = request.GET.get('category')
    selected_type = request.GET.get('type')
    
    if selected_month:
        try:
            year, month = map(int, selected_month.split('-'))
            expenses = expenses.filter(date__year=year, date__month=month)
        except ValueError: pass
    if selected_category: expenses = expenses.filter(category__main_category__iexact=selected_category)
    if selected_type: expenses = expenses.filter(category__expense_type__iexact=selected_type)
        
    total_expenses = float(expenses.aggregate(Sum('amount'))['amount__sum'] or 0.0)
    monthly_budget = float(user.monthly_budget)
    remaining_budget = max(0.0, monthly_budget - total_expenses)
    
    total_income = float(Income.objects.filter(user=user).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    total_subs = float(Subscription.objects.filter(user=user).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    net_worth = float(user.assets) - float(user.loans)
    savings_ratio = (total_income - total_expenses) / total_income * 100 if total_income > 0 else 0
    subs_list = list(Subscription.objects.filter(user=user).order_by('next_due_date').values()[:4])
    
    health_score = 100
    if monthly_budget > 0:
        usage = total_expenses / monthly_budget
        health_score -= 50 if usage > 1.0 else int(usage * 40)
    health_score += 10
    health_score = max(0, min(100, health_score))
    
    persona = get_financial_personality(user)
    
    forecast_spend = predict_next_month_spending(user)
    if total_expenses > monthly_budget:
        risk_level, risk_css, risk_reason = "CRITICAL", "danger", "Expenses exceeded monthly budget!"
    elif forecast_spend > monthly_budget * 0.9:
        risk_level, risk_css, risk_reason = "HIGH", "warning", "Forecast predicts near budget breach."
    else:
        risk_level, risk_css, risk_reason = "LOW", "success", "Spending is perfectly stable."
        
    category_data = list(expenses.values('category__main_category').annotate(total=Sum('amount')))
    pie_labels = [item['category__main_category'] or 'Uncategorized' for item in category_data]
    pie_data = [float(item['total']) for item in category_data]
    
    pmode_data = list(expenses.values('payment_mode').annotate(total=Sum('amount')))
    pmode_labels = [item['payment_mode'] for item in pmode_data]
    pmode_data_values = [float(item['total']) for item in pmode_data]
    
    bar_labels, bar_data, income_bar_data = [], [], []
    today = datetime.today()
    for i in range(5, -1, -1):
        d = today - relativedelta(months=i)
        bar_labels.append(d.strftime('%b %Y'))
        m_total = float(Expense.objects.filter(user=user, date__year=d.year, date__month=d.month).aggregate(Sum('amount'))['amount__sum'] or 0.0)
        i_total = float(Income.objects.filter(user=user, date__year=d.year, date__month=d.month).aggregate(Sum('amount'))['amount__sum'] or 0.0)
        bar_data.append(m_total)
        income_bar_data.append(i_total)
        
    mood_data = list(expenses.values('mood').annotate(total=Sum('amount')))
    mood_labels = [item['mood'] for item in mood_data]
    mood_amounts = [float(item['total']) for item in mood_data]
    
    suggestions = []
    food_total = sum(d for l, d in zip(pie_labels, pie_data) if l and 'food' in l.lower())
    avg_food = 5000
    if food_total > avg_food * 1.5:
        suggestions.append(f"🍔 You spend {int((food_total/avg_food)*100 - 100)}% more than average users on food!")
    elif food_total < avg_food:
        suggestions.append(f"🥦 You spend less than average users on food. Great discipline!")
    if total_subs > total_income * 0.1 and total_income > 0:
        suggestions.append("📺 Subscriptions eating up your income! Review your recurring bills.")
    if not suggestions: suggestions.append("🌟 Your finances look amazing! Keep saving.")
    
    category_totals = [{'category': l, 'total': d} for l, d in zip(pie_labels, pie_data)]
    
    context = {
        'total_expenses': total_expenses,
        'remaining_budget': remaining_budget,
        'health_score': health_score,
        'forecast_spend': forecast_spend,
        'persona': persona,
        'risk_level': risk_level,
        'risk_css': risk_css,
        'risk_reason': risk_reason,
        'total_income': total_income,
        'total_subs': total_subs,
        'net_worth': net_worth,
        'savings_ratio': savings_ratio,
        'subs_list': subs_list,
        'pie_labels': pie_labels, 'pie_data': pie_data,
        'pmode_labels': pmode_labels, 'pmode_data': pmode_data_values,
        'bar_labels': bar_labels, 'bar_data': bar_data, 'income_bar_data': income_bar_data,
        'mood_labels': mood_labels, 'mood_data': mood_amounts,
        'category_totals': category_totals,
        'suggestions': suggestions,
        'split_owed': float(ExpenseSplit.objects.filter(user=user, is_settled=False).aggregate(Sum('amount_owed'))['amount_owed__sum'] or 0.0),
        'split_paid': float(SharedExpense.objects.filter(paid_by=user).aggregate(Sum('amount'))['amount__sum'] or 0.0),
        'goals': list(Goal.objects.filter(user=user, status='Active').values()[:3]),
        'recent_expenses': list(expenses.order_by('-date').values()[:5]),
        'all_categories': [c for c in Expense.objects.filter(user=user).values_list('category__main_category', flat=True).distinct() if c],
        'all_types': list(Expense.objects.filter(user=user).values_list('category__expense_type', flat=True).distinct()),
    }
    return Response(context)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def chatbot_api(request):
    try:
        msg = request.data.get('message', '').lower()
        response = "I'm your Financial AI. Ask me about your 'summary', 'budget', 'saving tips', or 'goals'!"
        if 'summary' in msg:
            spent = Expense.objects.filter(user=request.user).aggregate(Sum('amount'))['amount__sum'] or 0
            response = f"Your total expenses recorded so far amount to ₹{spent}. Try viewing the Category Distribution chart for details."
        elif 'budget' in msg:
            response = f"Your monthly budget is currently set to ₹{request.user.monthly_budget}. You can update it in the Settings module."
        elif 'tip' in msg or 'saving' in msg:
            response = "Saving Tip: The 50/30/20 rule! Allocate 50% to Needs, 30% to Wants, and 20% to Savings or paying off debt."
        elif 'goal' in msg:
            response = "You can create financial goals from the sidebar! Automating your savings via recurring transfers is the easiest way to reach them."
        
        return Response({'reply': response})
    except Exception as e:
        return Response({'reply': "I seem to be malfunctioning. Check your connection."}, status=400)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def export_excel(request):
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="expenses_report.csv"'
    writer = csv.writer(response)
    writer.writerow(['Date', 'Description', 'Category', 'Payment Mode', 'Mood', 'Type', 'Amount'])
    for exp in Expense.objects.filter(user=request.user).order_by('-date'):
        writer.writerow([exp.date, exp.description, exp.category.main_category if exp.category else 'N/A', exp.payment_mode, exp.mood, exp.category.expense_type if exp.category else 'N/A', exp.amount])
    return response

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def export_pdf(request):
    try:
        from reportlab.pdfgen import canvas
        from reportlab.lib.pagesizes import letter
    except ImportError:
        return HttpResponse("ReportLab is not installed.", status=500)

    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="expenses_report.pdf"'
    p = canvas.Canvas(response, pagesize=letter)
    p.drawString(100, 750, f"Expense Report for {request.user.username}")
    
    y = 700
    p.drawString(100, y, "Date | Description | Category | Amount")
    y -= 20
    for exp in Expense.objects.filter(user=request.user).order_by('-date'):
        if y < 50:
            p.showPage()
            y = 750
        p.drawString(100, y, f"{exp.date} | {exp.description[:20]} | {exp.category} | Rs. {exp.amount}")
        y -= 20
        
    p.showPage()
    p.save()
    return response

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def records_view(request):
    expenses = list(Expense.objects.filter(user=request.user).order_by('-date').values())
    incomes = list(Income.objects.filter(user=request.user).order_by('-date').values())
    return Response({'expenses': expenses, 'incomes': incomes})

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def investments_view(request):
    accounts = list(Account.objects.filter(user=request.user, account_type='Investment').values())
    accounts_qs = Account.objects.filter(user=request.user, account_type='Investment')
    dividends = list(Dividend.objects.filter(account__in=accounts_qs).order_by('-date').values())
    fees = list(Fee.objects.filter(account__in=accounts_qs).order_by('-date').values())
    
    total_invested = float(accounts_qs.aggregate(Sum('balance'))['balance__sum'] or 0.0)
    total_dividends = float(Dividend.objects.filter(account__in=accounts_qs).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    total_fees = float(Fee.objects.filter(account__in=accounts_qs).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    
    context = {
        'accounts': accounts,
        'dividends': dividends,
        'fees': fees,
        'total_invested': total_invested,
        'total_dividends': total_dividends,
        'total_fees': total_fees,
    }
    return Response(context)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def statistics_view(request):
    period = request.GET.get('period', '30')
    try:
        days = int(period)
    except:
        days = 30
        
    start_date = datetime.today() - relativedelta(days=days)
    
    expenses_period = float(Expense.objects.filter(user=request.user, date__gte=start_date).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    incomes_period = float(Income.objects.filter(user=request.user, date__gte=start_date).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    delta = incomes_period - expenses_period
    
    accounts = Account.objects.filter(user=request.user).order_by('-balance')
    top_account = accounts.first().name if accounts.exists() else None
    
    subs = Subscription.objects.filter(user=request.user).order_by('category', 'next_due_date')
    
    labels = []
    data = []
    current_balance = float(Account.objects.filter(user=request.user).aggregate(Sum('balance'))['balance__sum'] or 0.0)
    
    past_6_months = datetime.today() - relativedelta(months=6)
    hist_income = float(Income.objects.filter(user=request.user, date__gte=past_6_months).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    hist_expenses = float(Expense.objects.filter(user=request.user, date__gte=past_6_months).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    avg_monthly_net = (hist_income - hist_expenses) / 6.0
    
    today = datetime.today()
    running_balance = current_balance
    
    for i in range(1, 7):
        d = today + relativedelta(months=i)
        labels.append(d.strftime('%b %Y'))
        
        sub_cost_this_month = 0
        for s in subs:
            if s.billing_cycle == 'Monthly':
                sub_cost_this_month += float(s.amount)
            elif s.billing_cycle == 'Yearly' and s.next_due_date.month == d.month:
                sub_cost_this_month += float(s.amount)
                
        running_balance += avg_monthly_net - sub_cost_this_month
        data.append(round(running_balance, 2))
    
    context = {
        'period': days,
        'delta': delta,
        'top_account': top_account,
        'accounts': list(accounts.values()),
        'subscriptions': list(subs.values()),
        'forecast_labels': labels,
        'forecast_data': data
    }
    return Response(context)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def cash_flow_view(request):
    labels, cash_in, cash_out = [], [], []
    net_savings = []
    
    today = datetime.today()
    for i in range(5, -1, -1):
        d = today - relativedelta(months=i)
        period_label = d.strftime('%b %Y')
        labels.append(period_label)
        m_out = float(Expense.objects.filter(user=request.user, date__year=d.year, date__month=d.month).aggregate(Sum('amount'))['amount__sum'] or 0.0)
        m_in = float(Income.objects.filter(user=request.user, date__year=d.year, date__month=d.month).aggregate(Sum('amount'))['amount__sum'] or 0.0)
        cash_in.append(m_in)
        cash_out.append(m_out)
        net_savings.append({'period': period_label, 'saved': m_in - m_out})
        
    best_period = max(net_savings, key=lambda x: x['saved']) if net_savings else None
    worst_period = min(net_savings, key=lambda x: x['saved']) if net_savings else None

    context = {
        'labels': labels,
        'cash_in': cash_in,
        'cash_out': cash_out,
        'best_period': best_period,
        'worst_period': worst_period
    }
    return Response(context)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def spending_view(request):
    expenses = Expense.objects.filter(user=request.user)
    category_data = list(expenses.values('category__main_category').annotate(total=Sum('amount')).order_by('-total'))
    labels = [item['category__main_category'] or 'Uncategorized' for item in category_data]
    data = [float(item['total']) for item in category_data]
    
    cat_list = [{'name': item['category__main_category'] or 'Uncategorized', 'amount': float(item['total'])} for item in category_data]
    
    context = {
        'labels': labels,
        'data': data,
        'categories': cat_list
    }
    return Response(context)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def learning_hub(request):
    return Response({"message": "Learning hub API is active. Provide localized content or video links here."})

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def outlook_view(request):
    subs = Subscription.objects.filter(user=request.user).order_by('category', 'next_due_date')
    
    labels = []
    data = []
    current_balance = float(Account.objects.filter(user=request.user).aggregate(Sum('balance'))['balance__sum'] or 0.0)
    
    past_6_months = datetime.today() - relativedelta(months=6)
    hist_income = float(Income.objects.filter(user=request.user, date__gte=past_6_months).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    hist_expenses = float(Expense.objects.filter(user=request.user, date__gte=past_6_months).aggregate(Sum('amount'))['amount__sum'] or 0.0)
    
    avg_monthly_net = (hist_income - hist_expenses) / 6.0
    
    today = datetime.today()
    running_balance = current_balance
    
    for i in range(1, 7):
        d = today + relativedelta(months=i)
        labels.append(d.strftime('%b %Y'))
        
        sub_cost_this_month = 0
        for s in subs:
            if s.billing_cycle == 'Monthly':
                sub_cost_this_month += float(s.amount)
            elif s.billing_cycle == 'Yearly' and s.next_due_date.month == d.month:
                sub_cost_this_month += float(s.amount)
                
        running_balance += avg_monthly_net - sub_cost_this_month
        data.append(round(running_balance, 2))
        
    context = {
        'subscriptions': list(subs.values()),
        'labels': labels,
        'data': data
    }
    return Response(context)
