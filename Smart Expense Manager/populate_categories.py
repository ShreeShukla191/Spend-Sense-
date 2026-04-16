import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "expense_tracker.settings")
django.setup()

from expenses.models import Category, Expense

# Clear existing Expenses so that ForeignKey conflict doesn't block migration
Expense.objects.all().delete()
Category.objects.all().delete()

categories_data = [
    # Personal Expenses
    ("Personal", "Food & Dining", "Breakfast", "🍽️", "#ff9f43"),
    ("Personal", "Food & Dining", "Lunch", "🍽️", "#ff9f43"),
    ("Personal", "Food & Dining", "Dinner", "🍽️", "#ff9f43"),
    ("Personal", "Food & Dining", "Snacks", "🍔", "#ff9f43"),
    ("Personal", "Food & Dining", "Tea/Coffee", "☕", "#ff9f43"),
    ("Personal", "Food & Dining", "Restaurant", "🍕", "#ff9f43"),
    ("Personal", "Food & Dining", "Online Food Order", "🛵", "#ff9f43"),
    ("Personal", "Food & Dining", "Groceries", "🛒", "#28c76f"),
    ("Personal", "Food & Dining", "Fruits & Vegetables", "🍎", "#28c76f"),
    ("Personal", "Food & Dining", "Dairy Products", "🥛", "#28c76f"),

    ("Personal", "Transport & Travel", "Auto / Rickshaw", "🛺", "#00cfe8"),
    ("Personal", "Transport & Travel", "Cab / Uber", "🚕", "#00cfe8"),
    ("Personal", "Transport & Travel", "Metro", "🚇", "#00cfe8"),
    ("Personal", "Transport & Travel", "Bus", "🚌", "#00cfe8"),
    ("Personal", "Transport & Travel", "Train", "🚆", "#00cfe8"),
    ("Personal", "Transport & Travel", "Fuel / Petrol", "⛽", "#ff4c51"),
    ("Personal", "Transport & Travel", "Parking", "🅿️", "#00cfe8"),
    ("Personal", "Transport & Travel", "Toll Charges", "🛣️", "#00cfe8"),
    ("Personal", "Transport & Travel", "Vehicle Service", "🔧", "#00cfe8"),

    ("Personal", "Home & Living", "Rent", "🏠", "#7367f0"),
    ("Personal", "Home & Living", "Electricity Bill", "💡", "#ffb400"),
    ("Personal", "Home & Living", "Water Bill", "🚰", "#00cfe8"),
    ("Personal", "Home & Living", "Gas Cylinder", "🔥", "#ff4c51"),
    ("Personal", "Home & Living", "Internet / WiFi", "📶", "#7367f0"),
    ("Personal", "Home & Living", "Maid Salary", "🧹", "#28c76f"),
    ("Personal", "Home & Living", "Cleaning Supplies", "🧽", "#28c76f"),
    ("Personal", "Home & Living", "Home Repair", "🛠️", "#82868b"),
    ("Personal", "Home & Living", "Furniture", "🛋️", "#82868b"),

    ("Personal", "Utilities & Digital", "Mobile Recharge", "📱", "#00cfe8"),
    ("Personal", "Utilities & Digital", "OTT Subscription", "📺", "#ff4c51"),
    ("Personal", "Utilities & Digital", "Software Subscription", "💻", "#7367f0"),
    ("Personal", "Utilities & Digital", "App Purchases", "🛒", "#00cfe8"),
    ("Personal", "Utilities & Digital", "Cloud Storage", "☁️", "#00cfe8"),
    ("Personal", "Utilities & Digital", "Gaming Purchase", "🎮", "#ff4c51"),

    ("Personal", "Health & Medical", "Doctor Visit", "👨‍⚕️", "#ff4c51"),
    ("Personal", "Health & Medical", "Medicines", "💊", "#ff4c51"),
    ("Personal", "Health & Medical", "Lab Tests", "🔬", "#ff4c51"),
    ("Personal", "Health & Medical", "Gym Fees", "🏋️", "#ffb400"),
    ("Personal", "Health & Medical", "Yoga Classes", "🧘‍♀️", "#ffb400"),
    ("Personal", "Health & Medical", "Health Insurance", "🛡️", "#28c76f"),

    ("Personal", "Education", "College Fees", "🎓", "#7367f0"),
    ("Personal", "Education", "Online Courses", "💻", "#7367f0"),
    ("Personal", "Education", "Books", "📚", "#7367f0"),
    ("Personal", "Education", "Stationery", "✏️", "#82868b"),
    ("Personal", "Education", "Exam Fees", "📝", "#7367f0"),
    ("Personal", "Education", "Coaching", "👨‍🏫", "#7367f0"),

    ("Personal", "Personal Care", "Haircut", "✂️", "#82868b"),
    ("Personal", "Personal Care", "Cosmetics", "💄", "#ff9f43"),
    ("Personal", "Personal Care", "Skincare", "🧴", "#00cfe8"),
    ("Personal", "Personal Care", "Salon", "💅", "#ff9f43"),
    ("Personal", "Personal Care", "Clothes", "👕", "#7367f0"),
    ("Personal", "Personal Care", "Footwear", "👟", "#7367f0"),

    # Extra Expenses
    ("Extra", "Shopping", "Clothing Shopping", "👕", "#7367f0"),
    ("Extra", "Shopping", "Electronics", "📱", "#00cfe8"),
    ("Extra", "Shopping", "Accessories", "👜", "#ff9f43"),
    ("Extra", "Shopping", "Gifts", "🎁", "#ff4c51"),
    ("Extra", "Shopping", "Amazon / Flipkart Orders", "📦", "#ffb400"),

    ("Extra", "Entertainment", "Movie Ticket", "🎬", "#7367f0"),
    ("Extra", "Entertainment", "Outing", "🎢", "#ff9f43"),
    ("Extra", "Entertainment", "Party", "🎉", "#ff4c51"),
    ("Extra", "Entertainment", "Games", "🕹️", "#00cfe8"),
    ("Extra", "Entertainment", "Concert", "🎤", "#7367f0"),

    ("Extra", "Travel & Vacation", "Flight Tickets", "✈️", "#00cfe8"),
    ("Extra", "Travel & Vacation", "Hotel Booking", "🏨", "#7367f0"),
    ("Extra", "Travel & Vacation", "Travel Food", "🍔", "#ff9f43"),
    ("Extra", "Travel & Vacation", "Tourism Activities", "🏝️", "#28c76f"),

    ("Extra", "Celebration", "Birthday", "🎂", "#ff4c51"),
    ("Extra", "Celebration", "Anniversary", "💍", "#ff9f43"),
    ("Extra", "Celebration", "Festival Expenses", "🏮", "#ffb400"),
    ("Extra", "Celebration", "Decorations", "🎈", "#00cfe8"),

    ("Extra", "Luxury / Misc", "Gadgets", "⌚", "#82868b"),
    ("Extra", "Luxury / Misc", "Jewelry", "💎", "#ffb400"),
    ("Extra", "Luxury / Misc", "Premium Items", "🍾", "#7367f0"),
    ("Extra", "Luxury / Misc", "Random Spending", "💸", "#ff4c51"),

    # Savings
    ("Saving", "Savings & Investments", "SIP", "📈", "#28c76f"),
    ("Saving", "Savings & Investments", "Fixed Deposit", "🏦", "#28c76f"),
    ("Saving", "Savings & Investments", "Stocks", "📊", "#28c76f"),
    ("Saving", "Savings & Investments", "Mutual Funds", "💹", "#28c76f"),
    ("Saving", "Savings & Investments", "Emergency Fund", "🚨", "#ff4c51"),

    # Income
    ("Income", "Income", "Salary", "💼", "#28c76f"),
    ("Income", "Income", "Freelance", "💻", "#00cfe8"),
    ("Income", "Income", "Pocket Money", "💵", "#ffb400"),
    ("Income", "Income", "Scholarship", "🎓", "#7367f0"),
    ("Income", "Income", "Refund", "🔄", "#82868b"),
    ("Income", "Income", "Bonus", "🎊", "#ff9f43"),
    ("Income", "Income", "Gift Received", "🎁", "#ff4c51"),
]

for item in categories_data:
    Category.objects.create(
        expense_type=item[0],
        main_category=item[1],
        sub_category=item[2],
        icon=item[3],
        color=item[4]
    )

print(f"Successfully seeded {len(categories_data)} extreme precision categories.")
