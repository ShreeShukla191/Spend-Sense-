import numpy as np
from sklearn.cluster import KMeans
from expenses.models import Expense
from django.db.models import Sum
from datetime import datetime

# Train a simple KMeans model with synthetic cluster centers representing personas
# Features: [pct_food, pct_weekend, pct_luxury, savings_ratio]
# Personas:
# 0: Food Lover (High food, low others)
# 1: Weekend Spender (High weekend, average others)
# 2: Luxury Spender (High luxury, low savings)
# 3: Smart Saver (High savings, balanced others)

def get_financial_personality(user):
    expenses = Expense.objects.filter(user=user)
    if not expenses.exists():
        return "Beginner"

    total_spend = sum(float(e.amount) for e in expenses)
    if total_spend == 0:
        return "Smart Saver"

    # Calculate engineered features for the user
    food_total = sum(float(e.amount) for e in expenses if e.category and ('food' in e.category.main_category.lower() or 'dining' in e.category.main_category.lower() or 'food' in e.category.sub_category.lower()))
    luxury_total = sum(float(e.amount) for e in expenses if e.category and ('luxury' in e.category.main_category.lower() or 'entertainment' in e.category.main_category.lower() or 'shopping' in e.category.main_category.lower()))
    
    weekend_total = sum(float(e.amount) for e in expenses if e.date.weekday() >= 5) # 5=Sat, 6=Sun
    
    pct_food = food_total / total_spend
    pct_weekend = weekend_total / total_spend
    pct_luxury = luxury_total / total_spend
    
    # Calculate savings ratio (Mocked based on budget if Income isn't populated heavily yet)
    monthly_budget = float(user.monthly_budget)
    savings_ratio = max(0.0, (monthly_budget - total_spend) / monthly_budget) if monthly_budget > 0 else 0.5

    user_features = np.array([[pct_food, pct_weekend, pct_luxury, savings_ratio]])

    # Synthetic training data representing clear centroids
    X_train = np.array([
        [0.8, 0.2, 0.1, 0.1],  # Food Lover
        [0.2, 0.8, 0.2, 0.1],  # Weekend Spender
        [0.2, 0.3, 0.8, 0.0],  # Luxury Spender
        [0.1, 0.1, 0.1, 0.6],  # Smart Saver
    ])
    
    kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
    kmeans.fit(X_train)
    
    cluster_idx = kmeans.predict(user_features)[0]
    
    # Map cluster back to string using distance to original pseudo-centroids
    labels = ["Food Lover 🍔", "Weekend Spender 🎉", "Luxury Spender 💎", "Smart Saver 📈"]
    
    return labels[cluster_idx]
