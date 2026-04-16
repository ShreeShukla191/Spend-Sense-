from django.db import models
from django.conf import settings
from django.utils import timezone

class Category(models.Model):
    EXPENSE_TYPES = [
        ('Personal', '1️⃣ Personal Expenses (Daily Needs)'),
        ('Extra', '2️⃣ Extra Expenses (Lifestyle / Optional)'),
        ('Saving', '3️⃣ Savings & Investments'),
        ('Income', '4️⃣ Income Category'),
    ]
    expense_type = models.CharField(max_length=20, choices=EXPENSE_TYPES)
    main_category = models.CharField(max_length=100)
    sub_category = models.CharField(max_length=100)
    icon = models.CharField(max_length=10, default='📌')
    color = models.CharField(max_length=20, default='#6c757d')

    class Meta:
        ordering = ['expense_type', 'main_category', 'sub_category']

    def __str__(self):
        return f"{self.expense_type} -> {self.main_category} -> {self.sub_category}"

class Expense(models.Model):
    PAYMENT_MODES = [
        ('Cash', 'Cash'),
        ('Credit Card', 'Credit Card'),
        ('Debit Card', 'Debit Card'),
        ('UPI', 'UPI'),
        ('Net Banking', 'Net Banking'),
    ]

    MOOD_CHOICES = [
        ('Happy', 'Happy 😄'),
        ('Sad', 'Sad 😢'),
        ('Neutral', 'Neutral 😐'),
        ('Angry', 'Angry 😠'),
        ('Excited', 'Excited 🤩'),
        ('Anxious', 'Anxious 😰'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.CharField(max_length=255)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    payment_mode = models.CharField(max_length=20, choices=PAYMENT_MODES, default='Cash')
    mood = models.CharField(max_length=20, choices=MOOD_CHOICES, default='Neutral')
    date = models.DateField()
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date', '-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.description} (₹{self.amount})"

class Income(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='incomes')
    source = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField(default=timezone.now)
    
    def __str__(self):
        return f"{self.source} - ₹{self.amount}"

class Subscription(models.Model):
    CYCLE_CHOICES = (
        ('Monthly', 'Monthly'),
        ('Yearly', 'Yearly')
    )
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='subscriptions')
    service_name = models.CharField(max_length=100)
    category = models.CharField(max_length=50, default='General')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    next_due_date = models.DateField()
    billing_cycle = models.CharField(max_length=20, default='Monthly', choices=CYCLE_CHOICES)
    
    def __str__(self):
        return self.service_name

class Account(models.Model):
    ACCOUNT_TYPES = [
        ('Bank', 'Bank Account'),
        ('Cash', 'Cash'),
        ('Investment', 'Investment Account'),
    ]
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='accounts')
    name = models.CharField(max_length=100)
    account_type = models.CharField(max_length=20, choices=ACCOUNT_TYPES, default='Bank')
    balance = models.DecimalField(max_digits=15, decimal_places=2, default=0.00)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.account_type}) - ₹{self.balance}"

class Dividend(models.Model):
    account = models.ForeignKey(Account, on_delete=models.CASCADE, related_name='dividends')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField(default=timezone.now)
    description = models.CharField(max_length=255, blank=True)

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)
        if is_new:
            self.account.balance += self.amount
            self.account.save()

    def __str__(self):
        return f"Dividend of ₹{self.amount} for {self.account.name}"

class Fee(models.Model):
    account = models.ForeignKey(Account, on_delete=models.CASCADE, related_name='fees')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField(default=timezone.now)
    description = models.CharField(max_length=255, blank=True)

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)
        if is_new:
            self.account.balance -= self.amount
            self.account.save()

    def __str__(self):
        return f"Fee of ₹{self.amount} on {self.account.name}"
