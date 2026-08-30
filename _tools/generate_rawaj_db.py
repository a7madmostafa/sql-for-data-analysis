"""
Generates Databases/rawaj_db.sql — the full schema + seed data for Rawaj, the fictional
Egyptian e-commerce marketplace that replaces Parch & Posey (see Databases/rawaj_erd.md for the
full design notes and business rules this script encodes).

Usage:
    python _tools/generate_rawaj_db.py

Pure stdlib (random, datetime) — no external dependencies. Uses a fixed random seed, so re-running
produces byte-identical output; regenerate rather than hand-edit the resulting .sql file.
"""

import random
from datetime import date, datetime, timedelta

random.seed(42)

OUT_PATH = "Databases/rawaj_db.sql"

# ============================================================
# Curated reference data
# ============================================================

MALE_FIRST_NAMES = [
    "Ahmed", "Mohamed", "Mahmoud", "Youssef", "Omar", "Khaled", "Karim", "Tarek", "Amr", "Hassan",
    "Hossam", "Sherif", "Ibrahim", "Mostafa", "Ayman", "Wael", "Sameh", "Adel", "Ashraf", "Ramy",
    "Hany", "Emad", "Waleed", "Fady", "Bassem", "Nabil", "Sayed", "Gamal", "Magdy", "Osama",
]
FEMALE_FIRST_NAMES = [
    "Mariam", "Nourhan", "Salma", "Aya", "Fatma", "Nour", "Yasmin", "Dina", "Heba", "Rania",
    "Mona", "Nada", "Amira", "Sara", "Marwa", "Reem", "Hala", "Nesma", "Doaa", "Basma",
    "Shaimaa", "Yara", "Eman", "Ghada", "Radwa", "Asmaa", "Manal", "Samar", "Nermin", "Alia",
]
LAST_NAMES = [
    "El-Sayed", "Abdelrahman", "Farouk", "Hassanein", "Zaki", "Naguib", "Fahmy", "Barakat",
    "El-Gendy", "Mahmoud", "Hegazy", "Kamal", "El-Shazly", "Rashed", "Aziz", "Sabry", "Fawzy",
    "Salah", "El-Masry", "Abdel-Latif", "Younis", "El-Nabawy", "Shokry", "Kandil", "Hamdy",
    "El-Kholy", "Ragab", "Soliman", "Metwally", "El-Bahnasy",
]
NEIGHBORHOODS = [
    "Maadi", "Nasr City", "Heliopolis", "Zamalek", "Mohandessin", "Dokki", "Downtown",
    "New Cairo", "6th of October", "Shubra", "Agouza", "Haram", "Rehab", "Sheikh Zayed",
    "Mansoura", "Smouha", "Miami", "Sidi Gaber",
]

GOVERNORATES = ["Cairo", "Giza", "Alexandria", "Qalyubia", "Sharqia", "Assiut"]
GOVERNORATE_WEIGHTS = [0.35, 0.25, 0.15, 0.10, 0.10, 0.05]

CATEGORIES = ["Electronics", "Fashion", "Home & Kitchen", "Groceries", "Health & Beauty", "Baby & Kids"]
CATEGORY_CODES = {"Electronics": "ELC", "Fashion": "FAS", "Home & Kitchen": "HNK",
                   "Groceries": "GRO", "Health & Beauty": "HNB", "Baby & Kids": "BNK"}

BRAND_NAMES = [
    "Nile Tech", "Fayrouz Home", "Zahra Textiles", "Delta Electronics", "Karam Foods",
    "Sabeel Kitchenware", "Amana Appliances", "Rawnaq Fashion", "Basata Basics", "Nesma Baby",
    "Wafra Naturals", "El-Fanous Lighting", "Sanad Tools", "Marsa Home", "Qamar Beauty",
    "Baraka Pantry", "Sundus Fabrics", "Layali Cosmetics", "Hesn Electronics", "Rimal Living",
    "Nafoura Kids", "Souhoola Style", "Andalus Textiles", "Gawhara Beauty", "Fostat Foods",
    "Waha Appliances", "Sarayah Home", "Nasma Baby Care", "Mizan Health", "Dar El-Sena",
    "Khedma Electronics", "Rawasi Kitchen", "Tibr Fashion", "Nakhil Naturals", "Iman Baby",
    "Rehla Gear", "Sada Audio", "Warda Beauty", "Hilal Home", "Amal Essentials",
]

GROCERY_PRODUCTS = [
    "Koshari Spice Mix", "Ful Medames (Canned)", "Molokhia (Frozen, 500g)", "Halawa Tahini 500g",
    "Basmati Rice 5kg", "Baladi Bread (Pack of 6)", "Feta Cheese (Local) 250g", "Dukkah Mix 200g",
    "Green Tea with Mint", "Turkish Coffee 250g", "Tahini Paste 400g", "Dried Molokhia Leaves",
    "Sun-Dried Tomatoes 200g", "Egyptian Rice Vermicelli", "Karkade (Hibiscus Tea) 100g",
    "Mixed Nuts (Roasted) 500g", "Date Syrup 350ml", "Pickled Vegetables (Torshi) 1kg",
]
FASHION_PRODUCTS = [
    "Modest Abaya (Black)", "Men's Galabeya (Cotton)", "Cotton Hijab Scarf", "Embroidered Kaftan",
    "Men's Cotton Shirt", "Women's Wide-Leg Trousers", "Kids' School Uniform Set",
    "Printed Maxi Dress", "Men's Leather Sandals", "Women's Flat Shoes", "Wool Winter Coat",
    "Sports Tracksuit", "Denim Jacket", "Basic Cotton T-Shirt (Pack of 3)",
]
ELECTRONICS_PRODUCTS = [
    "Wireless Earbuds Pro", "27-inch LED Monitor", "Power Bank 20000mAh", "Bluetooth Speaker",
    "Smart Watch Fitness Tracker", "Wireless Mouse", "USB-C Fast Charger 65W", "Action Camera",
    "Noise-Cancelling Headphones", "Portable SSD 1TB", "Smart Home Plug", "LED Desk Lamp",
    "Mechanical Keyboard", "Phone Tripod Stand",
]
HOME_PRODUCTS = [
    "Non-Stick Cookware Set", "Electric Kettle 1.7L", "Ceramic Dinnerware Set (16pc)",
    "Air Fryer 5L", "Cotton Bedsheet Set (Queen)", "Blackout Curtains (Pair)", "Storage Baskets Set",
    "Stand Mixer 1000W", "Glass Food Containers Set", "Bamboo Cutting Board Set",
    "Memory Foam Pillow", "Electric Kettle & Toaster Set",
]
HEALTH_PRODUCTS = [
    "Vitamin C Effervescent Tablets", "Argan Oil Hair Serum", "Aloe Vera Moisturizer",
    "Electric Toothbrush", "Digital Body Scale", "Sunscreen SPF 50", "Facial Cleanser 200ml",
    "Multivitamin Capsules (60ct)", "Hand Sanitizer Gel 500ml", "Hair Dryer 2200W",
]
BABY_PRODUCTS = [
    "Baby Diapers (Size 3, 60ct)", "Infant Formula 900g", "Baby Wipes (Pack of 6)",
    "Baby Stroller (Foldable)", "Baby Bottle Set", "Kids' Building Blocks Set",
    "Baby Carrier Wrap", "Toddler Sippy Cup", "Baby Bath Tub", "Kids' Puzzle Set (24pc)",
]
CATEGORY_PRODUCTS = {
    "Electronics": ELECTRONICS_PRODUCTS, "Fashion": FASHION_PRODUCTS, "Home & Kitchen": HOME_PRODUCTS,
    "Groceries": GROCERY_PRODUCTS, "Health & Beauty": HEALTH_PRODUCTS, "Baby & Kids": BABY_PRODUCTS,
}

DELIVERY_PARTNERS = ["Sarie3", "Wasel Express", "TrackIt Egypt", "Fori Delivery", "Amana Logistics", "Nagm Delivery"]

EMAIL_DOMAINS = ["gmail.com", "yahoo.com", "hotmail.com", "outlook.com"]

CHANNELS = ["organic", "facebook", "instagram", "google", "direct"]
CHANNEL_WEIGHTS = [0.25, 0.25, 0.20, 0.20, 0.10]

# Order date range and Ramadan/Eid windows within it (approximate real dates) to bias density.
ORDER_START = date(2023, 6, 1)
ORDER_END = date(2025, 5, 31)
RAMADAN_EID_WINDOWS = [
    (date(2024, 3, 5), date(2024, 4, 15)),   # Ramadan + Eid al-Fitr 2024
    (date(2025, 2, 23), date(2025, 4, 5)),   # Ramadan + Eid al-Fitr 2025
]

TODAY = date(2025, 6, 15)  # fixed "generation date" so delivered_at/etc. stay consistent on rerun


def sql_str(value):
    if value is None:
        return "NULL"
    escaped = str(value).replace("\\", "\\\\").replace("'", "''")
    return f"'{escaped}'"


def sql_val(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, (date, datetime)):
        return f"'{value.isoformat(sep=' ') if isinstance(value, datetime) else value.isoformat()}'"
    return sql_str(value)


def weighted_choice(options, weights):
    return random.choices(options, weights=weights, k=1)[0]


def random_date(start, end):
    span = (end - start).days
    return start + timedelta(days=random.randint(0, span))


def random_order_date():
    """Ramadan/Eid-biased order date within ORDER_START..ORDER_END."""
    if random.random() < 0.30:
        window = random.choice(RAMADAN_EID_WINDOWS)
        d = random_date(window[0], window[1])
    else:
        d = random_date(ORDER_START, ORDER_END)
    return datetime.combine(d, datetime.min.time()) + timedelta(
        hours=random.randint(8, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
    )


def egyptian_name():
    first = random.choice(MALE_FIRST_NAMES + FEMALE_FIRST_NAMES)
    last = random.choice(LAST_NAMES)
    return first, last


def make_email(first, last):
    domain = random.choice(EMAIL_DOMAINS)
    sep = random.choice([".", "_", ""])
    suffix = str(random.randint(1, 999)) if random.random() < 0.4 else ""
    return f"{first.lower()}{sep}{last.lower().replace('-', '')}{suffix}@{domain}"


def make_shop_name(is_official, brand_names_pool):
    if is_official:
        return f"{random.choice(brand_names_pool)} Official Store"
    style = random.choice(["neighborhood_category", "owner_name", "generic"])
    if style == "neighborhood_category":
        neighborhood = random.choice(NEIGHBORHOODS)
        category_word = random.choice(["Electronics", "Fashion", "Home Goods", "Grocers", "Beauty", "Kids Store"])
        return f"{neighborhood} {category_word}"
    if style == "owner_name":
        first, last = egyptian_name()
        suffix = random.choice(["Store", "Trading", "Shop", "General Trading"])
        return f"{first} {last} {suffix}"
    return f"{random.choice(NEIGHBORHOODS)} {random.choice(['Mart', 'Bazaar', 'Corner Shop', 'Supplies'])}"


def make_sku(category, idx):
    return f"{CATEGORY_CODES[category]}-{idx:05d}"


def make_tracking_number(idx):
    return f"WSL{idx:08d}EG"


# ============================================================
# Generation — in topological (FK-dependency) order
# ============================================================

# --- account_managers ---
account_managers = []
for manager_id in range(1, 16):
    first, last = egyptian_name()
    hire_date = random_date(date(2019, 1, 1), date(2024, 6, 1))
    account_managers.append({"manager_id": manager_id, "manager_name": f"{first} {last}", "hire_date": hire_date})

# --- governorates ---
governorates = []
for i, name in enumerate(GOVERNORATES, start=1):
    manager_id = None if name == "Assiut" else random.choice(account_managers)["manager_id"]
    governorates.append({"governorate_id": i, "governorate_name": name, "manager_id": manager_id})

# --- brands ---
brands = [{"brand_id": i, "brand_name": name} for i, name in enumerate(BRAND_NAMES, start=1)]

# --- categories ---
categories = [{"category_id": i, "category_name": name} for i, name in enumerate(CATEGORIES, start=1)]

# --- delivery_partners ---
delivery_partners = [{"partner_id": i, "partner_name": name} for i, name in enumerate(DELIVERY_PARTNERS, start=1)]

# --- sellers ---
NUM_SELLERS = 200
sellers = []
for seller_id in range(1, NUM_SELLERS + 1):
    is_official = random.random() < 0.15
    gov_id = governorates[GOVERNORATES.index(weighted_choice(GOVERNORATES, GOVERNORATE_WEIGHTS))]["governorate_id"]
    signup_date = random_date(date(2021, 1, 1), date(2025, 3, 1))
    sellers.append({
        "seller_id": seller_id,
        "seller_name": make_shop_name(is_official, BRAND_NAMES),
        "governorate_id": gov_id,
        "is_official_store": is_official,
        "signup_date": signup_date,
    })

# --- customers ---
NUM_CUSTOMERS = 1200
customers = []
for customer_id in range(1, NUM_CUSTOMERS + 1):
    first, last = egyptian_name()
    gov_id = governorates[GOVERNORATES.index(weighted_choice(GOVERNORATES, GOVERNORATE_WEIGHTS))]["governorate_id"]
    has_email = random.random() >= 0.10
    signup_date = random_date(date(2021, 6, 1), date(2025, 4, 1))
    customers.append({
        "customer_id": customer_id,
        "first_name": first,
        "last_name": last,
        "email": make_email(first, last) if has_email else None,
        "governorate_id": gov_id,
        "signup_date": signup_date,
    })

# --- products ---
NUM_PRODUCTS = 400
products = []
category_cycle = []
# roughly even split across categories, cycling for a clean spread
for i in range(NUM_PRODUCTS):
    category_cycle.append(CATEGORIES[i % len(CATEGORIES)])
random.shuffle(category_cycle)
for product_id in range(1, NUM_PRODUCTS + 1):
    category = category_cycle[product_id - 1]
    category_id = categories[CATEGORIES.index(category)]["category_id"]
    name_pool = CATEGORY_PRODUCTS[category]
    base_name = random.choice(name_pool)
    brand = random.choice(brands)
    products.append({
        "product_id": product_id,
        "product_name": base_name,
        "category_id": category_id,
        "brand_id": brand["brand_id"],
        "sku": make_sku(category, product_id),
    })

# --- product_listings ---
product_listings = []
listing_id = 1
for product in products:
    num_listings = weighted_choice([1, 2, 3], [0.60, 0.30, 0.10])
    chosen_sellers = random.sample(sellers, k=min(num_listings, len(sellers)))
    base_price = round(random.uniform(50, 3000), 2)
    for seller in chosen_sellers:
        price = round(base_price * random.uniform(0.9, 1.15), 2)
        unit_cost = round(price * random.uniform(0.55, 0.80), 2)
        status = weighted_choice(["active", "inactive", "out_of_stock"], [0.85, 0.05, 0.10])
        stock = 0 if status == "out_of_stock" else random.randint(1, 200)
        listed_at = random_date(seller["signup_date"], date(2025, 5, 1))
        product_listings.append({
            "listing_id": listing_id,
            "product_id": product["product_id"],
            "seller_id": seller["seller_id"],
            "price": price,
            "unit_cost": unit_cost,
            "stock_quantity": stock,
            "listed_at": listed_at,
            "status": status,
        })
        listing_id += 1

listings_by_id = {l["listing_id"]: l for l in product_listings}
seller_by_id = {s["seller_id"]: s for s in sellers}

# --- orders (pass 1: everything except totals, which need order_items first) ---
NUM_ORDERS = 6000
orders = []
for order_id in range(1, NUM_ORDERS + 1):
    customer = random.choice(customers)
    order_date = random_order_date()
    status = weighted_choice(
        ["delivered", "shipped", "processing", "pending", "cancelled", "returned"],
        [0.63, 0.08, 0.05, 0.05, 0.12, 0.07],
    )
    payment_method = weighted_choice(
        ["cash_on_delivery", "credit_card", "mobile_wallet", "installment"], [0.65, 0.15, 0.15, 0.05]
    )
    if payment_method == "cash_on_delivery":
        payment_status = "paid" if status == "delivered" else ("failed" if status == "cancelled" and random.random() < 0.1 else "pending")
    else:
        payment_status = weighted_choice(["paid", "failed", "refunded"], [0.90, 0.05, 0.05]) if status != "cancelled" else "refunded"
    orders.append({
        "order_id": order_id,
        "customer_id": customer["customer_id"],
        "order_date": order_date,
        "status": status,
        "payment_method": payment_method,
        "payment_status": payment_status,
        # subtotal/shipping_fee/discount_amount/total_amount filled in after order_items generated
        "subtotal": 0.0, "shipping_fee": 0.0, "discount_amount": 0.0, "total_amount": 0.0,
    })

orders_by_id = {o["order_id"]: o for o in orders}

# --- order_items ---
order_items = []
order_item_id = 1
for order in orders:
    num_items = weighted_choice([1, 2, 3, 4], [0.45, 0.30, 0.15, 0.10])
    chosen_listings = random.sample(product_listings, k=min(num_items, len(product_listings)))
    subtotal = 0.0
    for listing in chosen_listings:
        quantity = weighted_choice([1, 2, 3], [0.70, 0.22, 0.08])
        price_at_purchase = listing["price"]
        if random.random() < 0.10:
            price_at_purchase = round(price_at_purchase * random.uniform(0.85, 1.15), 2)
        line_total = round(price_at_purchase * quantity, 2)
        subtotal += line_total
        order_items.append({
            "order_item_id": order_item_id,
            "order_id": order["order_id"],
            "listing_id": listing["listing_id"],
            "quantity": quantity,
            "unit_price_at_purchase": price_at_purchase,
        })
        order_item_id += 1
    shipping_fee = round(random.uniform(20, 60), 2)
    discount_amount = round(subtotal * random.uniform(0, 0.15), 2) if random.random() < 0.25 else 0.0
    order["subtotal"] = round(subtotal, 2)
    order["shipping_fee"] = shipping_fee
    order["discount_amount"] = discount_amount
    order["total_amount"] = round(subtotal + shipping_fee - discount_amount, 2)

# --- web_events ---
NUM_WEB_EVENTS = 9000
web_events = []
for event_id in range(1, NUM_WEB_EVENTS + 1):
    customer = random.choice(customers)
    occurred_at = random_order_date()
    channel = weighted_choice(CHANNELS, CHANNEL_WEIGHTS)
    web_events.append({
        "event_id": event_id,
        "customer_id": customer["customer_id"],
        "occurred_at": occurred_at,
        "channel": channel,
    })

# --- reviews (only for delivered orders' items, ~40% of those get one) ---
reviews = []
review_id = 1
delivered_items = [oi for oi in order_items if orders_by_id[oi["order_id"]]["status"] == "delivered"]
random.shuffle(delivered_items)
review_candidates = delivered_items[: int(len(delivered_items) * 0.40)]
for item in review_candidates:
    order = orders_by_id[item["order_id"]]
    rating = weighted_choice([5, 4, 3, 2, 1], [0.45, 0.30, 0.15, 0.06, 0.04])
    has_comment = random.random() < 0.65
    review_date = order["order_date"].date() + timedelta(days=random.randint(2, 14))
    reviews.append({
        "review_id": review_id,
        "order_item_id": item["order_item_id"],
        "customer_id": order["customer_id"],
        "rating": rating,
        "review_text": f"Rated {rating}/5 for this purchase." if has_comment else None,
        "review_date": review_date,
    })
    review_id += 1

# --- shipments (one per (order, seller) for orders with a dispatched status) ---
shipments = []
shipment_id = 1
SHIPPABLE_STATUSES = {"processing", "shipped", "delivered", "returned"}
items_by_order = {}
for oi in order_items:
    items_by_order.setdefault(oi["order_id"], []).append(oi)

for order in orders:
    if order["status"] not in SHIPPABLE_STATUSES:
        continue
    items = items_by_order.get(order["order_id"], [])
    sellers_in_order = {listings_by_id[oi["listing_id"]]["seller_id"] for oi in items}
    for seller_id in sellers_in_order:
        shipped_at = order["order_date"] + timedelta(hours=random.randint(6, 48))
        shipment_status = {
            "delivered": "delivered", "shipped": "in_transit",
            "processing": "pending", "returned": "returned",
        }[order["status"]]
        if shipment_status == "delivered" and random.random() < 0.03:
            shipment_status = "failed_delivery"
        delivered_at = None
        if shipment_status == "delivered":
            delivered_at = shipped_at + timedelta(days=random.randint(1, 5))
        shipments.append({
            "shipment_id": shipment_id,
            "order_id": order["order_id"],
            "seller_id": seller_id,
            "delivery_partner_id": random.choice(delivery_partners)["partner_id"],
            "tracking_number": make_tracking_number(shipment_id),
            "shipped_at": shipped_at,
            "delivered_at": delivered_at,
            "shipping_cost": round(random.uniform(15, 45), 2),
            "status": shipment_status,
        })
        shipment_id += 1


# ============================================================
# SQL emission
# ============================================================

def emit_insert(lines, table, columns, rows, batch_size=500):
    if not rows:
        return
    for start in range(0, len(rows), batch_size):
        batch = rows[start : start + batch_size]
        value_tuples = []
        for row in batch:
            values = ", ".join(sql_val(row[col]) for col in columns)
            value_tuples.append(f"({values})")
        lines.append(f"INSERT IGNORE INTO {table} ({', '.join(columns)}) VALUES\n " + ",\n ".join(value_tuples) + ";")


def build_sql():
    lines = []
    lines.append("CREATE DATABASE IF NOT EXISTS rawaj;")
    lines.append("USE rawaj;")
    lines.append("")

    lines.append("""CREATE TABLE IF NOT EXISTS account_managers (
    manager_id INT PRIMARY KEY,
    manager_name VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS governorates (
    governorate_id INT PRIMARY KEY,
    governorate_name VARCHAR(50) NOT NULL,
    manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES account_managers(manager_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS delivery_partners (
    partner_id INT PRIMARY KEY,
    partner_name VARCHAR(100) NOT NULL
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(150) NOT NULL,
    governorate_id INT NOT NULL,
    is_official_store BOOLEAN NOT NULL,
    signup_date DATE NOT NULL,
    FOREIGN KEY (governorate_id) REFERENCES governorates(governorate_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NULL,
    governorate_id INT NOT NULL,
    signup_date DATE NOT NULL,
    FOREIGN KEY (governorate_id) REFERENCES governorates(governorate_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    brand_id INT NOT NULL,
    sku VARCHAR(30) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS product_listings (
    listing_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    seller_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    listed_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    UNIQUE (product_id, seller_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    shipping_fee DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    listing_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price_at_purchase DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (listing_id) REFERENCES product_listings(listing_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS web_events (
    event_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    occurred_at DATETIME NOT NULL,
    channel VARCHAR(30) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS reviews (
    review_id INT PRIMARY KEY,
    order_item_id INT NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    rating TINYINT NOT NULL,
    review_text TEXT NULL,
    review_date DATE NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);""")
    lines.append("""CREATE TABLE IF NOT EXISTS shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    seller_id INT NOT NULL,
    delivery_partner_id INT NOT NULL,
    tracking_number VARCHAR(50) NOT NULL,
    shipped_at DATETIME NOT NULL,
    delivered_at DATETIME NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
    FOREIGN KEY (delivery_partner_id) REFERENCES delivery_partners(partner_id)
);""")
    lines.append("")

    emit_insert(lines, "account_managers", ["manager_id", "manager_name", "hire_date"], account_managers)
    emit_insert(lines, "governorates", ["governorate_id", "governorate_name", "manager_id"], governorates)
    emit_insert(lines, "brands", ["brand_id", "brand_name"], brands)
    emit_insert(lines, "categories", ["category_id", "category_name"], categories)
    emit_insert(lines, "delivery_partners", ["partner_id", "partner_name"], delivery_partners)
    emit_insert(lines, "sellers", ["seller_id", "seller_name", "governorate_id", "is_official_store", "signup_date"], sellers)
    emit_insert(lines, "customers", ["customer_id", "first_name", "last_name", "email", "governorate_id", "signup_date"], customers)
    emit_insert(lines, "products", ["product_id", "product_name", "category_id", "brand_id", "sku"], products)
    emit_insert(lines, "product_listings", ["listing_id", "product_id", "seller_id", "price", "unit_cost", "stock_quantity", "listed_at", "status"], product_listings)
    emit_insert(lines, "orders", ["order_id", "customer_id", "order_date", "status", "payment_method", "payment_status", "subtotal", "shipping_fee", "discount_amount", "total_amount"], orders)
    emit_insert(lines, "order_items", ["order_item_id", "order_id", "listing_id", "quantity", "unit_price_at_purchase"], order_items)
    emit_insert(lines, "web_events", ["event_id", "customer_id", "occurred_at", "channel"], web_events)
    emit_insert(lines, "reviews", ["review_id", "order_item_id", "customer_id", "rating", "review_text", "review_date"], reviews)
    emit_insert(lines, "shipments", ["shipment_id", "order_id", "seller_id", "delivery_partner_id", "tracking_number", "shipped_at", "delivered_at", "shipping_cost", "status"], shipments)

    return "\n".join(lines) + "\n"


def main():
    sql_text = build_sql()
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(sql_text)
    print(f"wrote {OUT_PATH}")
    print(f"  account_managers={len(account_managers)} governorates={len(governorates)} "
          f"brands={len(brands)} categories={len(categories)} delivery_partners={len(delivery_partners)}")
    print(f"  sellers={len(sellers)} customers={len(customers)} products={len(products)} "
          f"product_listings={len(product_listings)}")
    print(f"  orders={len(orders)} order_items={len(order_items)} web_events={len(web_events)} "
          f"reviews={len(reviews)} shipments={len(shipments)}")


if __name__ == "__main__":
    main()
