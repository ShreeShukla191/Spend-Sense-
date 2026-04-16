import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from expenses.models import Expense

def predict_next_month_spending(user):
    expenses = Expense.objects.filter(user=user)
    if not expenses.exists():
        return 0.0

    df = pd.DataFrame(list(expenses.values('amount', 'date')))
    df['date'] = pd.to_datetime(df['date'])
    df['month'] = df['date'].dt.to_period('M')
    
    monthly_spending = df.groupby('month')['amount'].sum().reset_index()
    monthly_spending['month_index'] = np.arange(len(monthly_spending))
    
    if len(monthly_spending) < 2:
        # Not enough data for regression
        return float(monthly_spending['amount'].mean())
        
    X = monthly_spending[['month_index']]
    y = monthly_spending['amount']
    
    model = LinearRegression()
    model.fit(X, y)
    
    # Predict for next month
    next_month_index = pd.DataFrame({'month_index': [len(monthly_spending)]})
    predicted_amount = model.predict(next_month_index)[0]
    
    return max(0.0, float(predicted_amount))
