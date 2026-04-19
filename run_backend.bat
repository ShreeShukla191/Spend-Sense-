@echo off
echo Starting Django Backend Server for SpendSense...
echo This server will be accessible from both this PC and other devices (like mobile phones) on your local Wi-Fi.
cd "Smart Expense Manager"
python manage.py runserver 0.0.0.0:8000
pause
