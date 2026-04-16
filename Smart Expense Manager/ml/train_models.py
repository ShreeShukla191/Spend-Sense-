import os
import sys
import django

# Add the project root to sys.path so django can find expense_tracker.settings
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'expense_tracker.settings')
django.setup()

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
from django.conf import settings

def train_category_model():
    data = [
        {"description": "Walmart groceries milk bread", "category": "Groceries"},
        {"description": "Uber ride home", "category": "Transport"},
        {"description": "Netflix subscription", "category": "Entertainment"},
        {"description": "Electricity bill", "category": "Utilities"},
        {"description": "McDonalds burger lunch", "category": "Food & Dining"},
        {"description": "Whole Foods vegetable", "category": "Groceries"},
        {"description": "Spotify Premium", "category": "Entertainment"},
        {"description": "Lyft to airport", "category": "Transport"},
        {"description": "Gas station fuel", "category": "Transport"},
        {"description": "Water bill payment", "category": "Utilities"},
        {"description": "Gym membership", "category": "Health"},
        {"description": "Pharmacy medicine", "category": "Health"},
        {"description": "Amazon shopping electronics", "category": "Shopping"},
    ]
    
    df = pd.DataFrame(data)
    
    model = make_pipeline(
        TfidfVectorizer(),
        LogisticRegression()
    )
    
    model.fit(df['description'], df['category'])
    
    model_path = os.path.join(settings.BASE_DIR, 'ml', 'category_model.pkl')
    joblib.dump(model, model_path)
    print(f"Model saved to {model_path}")

if __name__ == "__main__":
    train_category_model()
