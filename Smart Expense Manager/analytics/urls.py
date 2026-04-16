from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('export/excel/', views.export_excel, name='export-excel'),
    path('export/pdf/', views.export_pdf, name='export-pdf'),
    path('api/chatbot/', views.chatbot_api, name='chatbot-api'),
    path('learning/', views.learning_view, name='learning'),
    path('records/', views.records_view, name='records'),
    path('investments/', views.investments_view, name='investments'),
    path('statistics/', views.statistics_view, name='statistics'),
    path('cash-flow/', views.cash_flow_view, name='cash-flow'),
    path('spending/', views.spending_view, name='spending'),
    path('outlook/', views.outlook_view, name='outlook'),
]
