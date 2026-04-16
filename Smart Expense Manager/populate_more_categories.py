import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "expense_tracker.settings")
django.setup()

from expenses.models import Category

more_categories = [
    # New Personal
    ("Personal", "Pets", "Pet Food", "🐶", "#ff9f43"),
    ("Personal", "Pets", "Vet Visit", "🩺", "#ff4c51"),
    ("Personal", "Pets", "Pet Toys", "🦴", "#00cfe8"),
    ("Personal", "Childcare", "School Fees", "🎒", "#7367f0"),
    ("Personal", "Childcare", "Toys & Games", "🧸", "#00cfe8"),
    ("Personal", "Childcare", "Babysitting", "👶", "#28c76f"),
    ("Personal", "Taxes & Legal", "Income Tax", "🏛️", "#ea5455"),
    ("Personal", "Taxes & Legal", "Property Tax", "🏡", "#ea5455"),
    ("Personal", "Taxes & Legal", "Legal Consultation", "⚖️", "#ea5455"),
    ("Personal", "Logistics", "Courier & Post", "📦", "#ffb400"),
    
    # New Extra
    ("Extra", "Hobbies", "Arts & Crafts", "🎨", "#ff9f43"),
    ("Extra", "Hobbies", "Music Instruments", "🎸", "#7367f0"),
    ("Extra", "Hobbies", "Photography", "📷", "#00cfe8"),
    ("Extra", "Sports & Fitness", "Sports Gear", "⚽", "#ffb400"),
    ("Extra", "Sports & Fitness", "Marathon/Event Entry", "🏅", "#28c76f"),
    ("Extra", "Fine Dining", "Steakhouse", "🥩", "#ff4c51"),
    ("Extra", "Fine Dining", "Sushi/Seafood", "🍣", "#00cfe8"),
    ("Extra", "Digital Assets", "Crypto Purchase", "₿", "#ffb400"),
    ("Extra", "Digital Assets", "NFTs", "🖼️", "#7367f0"),
    ("Extra", "Charity", "Donations", "🤝", "#28c76f"),
    ("Extra", "Charity", "Crowdfunding", "🙌", "#00cfe8"),
    
    # New Savings
    ("Saving", "Savings & Investments", "Gold / Sovereign Bonds", "🪙", "#ffb400"),
    ("Saving", "Savings & Investments", "Real Estate SIP", "🏢", "#7367f0"),
    ("Saving", "Savings & Investments", "EPF / PPF", "💼", "#28c76f"),
    ("Saving", "Savings & Investments", "Crypto Staking", "⛏️", "#ff9f43"),
    
    # New Income
    ("Income", "Income", "Dividends", "📈", "#28c76f"),
    ("Income", "Income", "Rental Income", "🏠", "#28c76f"),
    ("Income", "Income", "Business Profit", "🏢", "#28c76f"),
    ("Income", "Income", "Cash Rewards", "💳", "#ffb400"),
]

added = 0
for item in more_categories:
    obj, created = Category.objects.get_or_create(
        expense_type=item[0],
        main_category=item[1],
        sub_category=item[2],
        defaults={'icon': item[3], 'color': item[4]}
    )
    if created:
        added += 1

print(f"Successfully added {added} NEW highly granular categories to the database.")
