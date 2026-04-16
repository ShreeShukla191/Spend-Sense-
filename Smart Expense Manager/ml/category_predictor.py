import os
import joblib
from django.conf import settings

def predict_category(description):
    model_path = os.path.join(settings.BASE_DIR, 'ml', 'category_model.pkl')
    if os.path.exists(model_path):
        model = joblib.load(model_path)
        return model.predict([description])[0]
    return "Other"
