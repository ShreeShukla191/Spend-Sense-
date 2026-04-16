import os
import django
import requests

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'expense_tracker.settings')
django.setup()

from users.models import User

# Ensure a test user exists
user, created = User.objects.get_or_create(username='tester', email='tester@example.com')
if created:
    user.set_password('testpass123')
    user.save()

# Get JWT
resp = requests.post('http://127.0.0.1:8000/auth/login/', json={'username': 'tester', 'password': 'testpass123'})
print("Login status:", resp.status_code)
if resp.status_code == 200:
    token = resp.json().get('access')
    headers = {'Authorization': f'Bearer {token}'}
    
    # Try hitting dashboard
    dash = requests.get('http://127.0.0.1:8000/', headers=headers)
    print("Dashboard status:", dash.status_code)
    if dash.status_code != 200:
        print("Error content:", dash.text[:1000])
        
    # Test split
    split = requests.get('http://127.0.0.1:8000/split/', headers=headers)
    print("Split status:", split.status_code)
    if split.status_code != 200:
        print("Error content:", split.text[:1000])
        
    # Test goals
    goals = requests.get('http://127.0.0.1:8000/goals/', headers=headers)
    print("Goals status:", goals.status_code)
else:
    print("Login output:", resp.text)
