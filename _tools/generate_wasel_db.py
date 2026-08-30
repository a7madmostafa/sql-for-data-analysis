"""
Generates Databases/wasel.sqlite -- the full schema + seed data for Wasel, the fictional
Egyptian ride-hailing app used for Day 07's project (see Databases/wasel_erd.md for the full
design notes and business rules this script encodes).

Unlike Rawaj (a MySQL database for Days 01-05), Wasel is a project-day dataset: it's queried
directly as a SQLite file via jupysql, same as the other project days, so this script builds the
.sqlite file directly instead of emitting a .sql script to load into a server.

Usage:
    python _tools/generate_wasel_db.py

Pure stdlib (random, sqlite3, datetime) -- no external dependencies. Uses a fixed random seed, so
re-running produces byte-identical output; regenerate rather than hand-edit the resulting file.
"""

import os
import random
import sqlite3
from datetime import date, datetime, timedelta

random.seed(7)

OUT_PATH = "Databases/wasel.sqlite"

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

CITIES = ["Cairo", "Giza", "Alexandria", "Qalyubia", "Sharqia", "Assiut", "Dakahlia", "Suez"]
CITY_WEIGHTS = [0.32, 0.24, 0.14, 0.09, 0.08, 0.05, 0.05, 0.03]
# Cairo/Giza/Qalyubia are practically one metro area -- drivers based there are the most likely
# to also cover a neighboring city.
METRO_CITIES = {"Cairo", "Giza", "Qalyubia"}

VEHICLE_TYPES = [
    {"type_name": "Economy", "base_fare": 12.00, "per_km_rate": 3.50},
    {"type_name": "Comfort", "base_fare": 18.00, "per_km_rate": 4.75},
    {"type_name": "XL", "base_fare": 25.00, "per_km_rate": 6.00},
]
VEHICLE_TYPE_WEIGHTS = [0.65, 0.25, 0.10]

MAKES_MODELS = [
    ("Toyota", "Corolla"), ("Hyundai", "Elantra"), ("Nissan", "Sunny"), ("Chevrolet", "Optra"),
    ("Kia", "Cerato"), ("Toyota", "Yaris"), ("Renault", "Logan"), ("Hyundai", "Accent"),
    ("Fiat", "Tipo"), ("Skoda", "Rapid"), ("MG", "5"), ("Toyota", "Fortuner"),
    ("Hyundai", "H1"), ("Chevrolet", "Captiva"),
]

PROMO_PREFIXES = ["WASEL", "RAMADAN", "WEEKEND", "FIRST", "EID", "SUMMER", "WELCOME", "CAIRO"]

TRIP_STATUSES = ["completed", "cancelled", "no_show"]
TRIP_STATUS_WEIGHTS = [0.86, 0.10, 0.04]
PAYMENT_METHODS = ["cash", "card", "mobile_wallet"]
PAYMENT_METHOD_WEIGHTS = [0.55, 0.20, 0.25]

NUM_DRIVERS = 180
NUM_RIDERS = 1000
NUM_PROMOTIONS = 15
NUM_TRIPS = 6000

START_DATE = date(2023, 6, 1)
END_DATE = date(2025, 5, 31)


# ============================================================
# Helpers
# ============================================================

def weighted_choice(options, weights):
    return random.choices(options, weights=weights, k=1)[0]


def random_date(start, end):
    delta_days = (end - start).days
    return start + timedelta(days=random.randint(0, delta_days))


def random_datetime_between(start_date, end_date):
    d = random_date(start_date, end_date)
    return datetime(d.year, d.month, d.day, random.randint(6, 23), random.randint(0, 59), random.randint(0, 59))


def egyptian_name():
    first = random.choice(MALE_FIRST_NAMES if random.random() < 0.6 else FEMALE_FIRST_NAMES)
    last = random.choice(LAST_NAMES)
    return first, last


def make_plate():
    letters = "".join(random.choices("ABDEFGHKLMNRSTUVXYZ", k=3))
    digits = random.randint(100, 999)
    return f"{letters} {digits}"


# ============================================================
# Generation -- in topological (FK-dependency) order
# ============================================================

cities = [{"city_id": i, "city_name": name} for i, name in enumerate(CITIES, start=1)]
city_id_by_name = {c["city_name"]: c["city_id"] for c in cities}


def weighted_city_id():
    return city_id_by_name[weighted_choice(CITIES, CITY_WEIGHTS)]


# --- drivers ---
drivers = []
for driver_id in range(1, NUM_DRIVERS + 1):
    first, last = egyptian_name()
    home_city_id = weighted_city_id()
    signup_date = random_date(START_DATE, END_DATE - timedelta(days=30))
    status = weighted_choice(["active", "inactive"], [0.88, 0.12])
    drivers.append({
        "driver_id": driver_id,
        "driver_name": f"{first} {last}",
        "home_city_id": home_city_id,
        "signup_date": signup_date,
        "status": status,
    })

# --- riders ---
riders = []
for rider_id in range(1, NUM_RIDERS + 1):
    first, last = egyptian_name()
    riders.append({
        "rider_id": rider_id,
        "rider_name": f"{first} {last}",
        "city_id": weighted_city_id(),
        "signup_date": random_date(START_DATE, END_DATE - timedelta(days=7)),
    })

# --- driver_city_coverage (genuine N:N -- every driver covers their home city, some cover more) ---
driver_city_coverage = []
for driver in drivers:
    covered = {driver["home_city_id"]}
    home_name = CITIES[driver["home_city_id"] - 1]
    extra_pool = list(METRO_CITIES - {home_name}) if home_name in METRO_CITIES else []
    if extra_pool and random.random() < 0.45:
        covered.add(city_id_by_name[random.choice(extra_pool)])
    elif random.random() < 0.10:
        covered.add(weighted_city_id())
    for city_id in covered:
        driver_city_coverage.append({"driver_id": driver["driver_id"], "city_id": city_id})

# --- vehicle_types ---
vehicle_types = [
    {"type_id": i, **vt} for i, vt in enumerate(VEHICLE_TYPES, start=1)
]

# --- vehicles (one per driver -- their own car) ---
vehicles = []
for driver in drivers:
    make, model = random.choice(MAKES_MODELS)
    type_id = weighted_choice([vt["type_id"] for vt in vehicle_types], VEHICLE_TYPE_WEIGHTS)
    vehicles.append({
        "vehicle_id": driver["driver_id"],
        "driver_id": driver["driver_id"],
        "type_id": type_id,
        "make": make,
        "model": model,
        "year": random.randint(2014, 2024),
        "plate_number": make_plate(),
    })
vehicle_type_by_id = {vt["type_id"]: vt for vt in vehicle_types}
vehicle_by_driver = {v["driver_id"]: v for v in vehicles}

# --- promotions ---
promotions = []
for promo_id in range(1, NUM_PROMOTIONS + 1):
    discount_type = weighted_choice(["percentage", "fixed"], [0.6, 0.4])
    discount_value = round(random.uniform(10, 30), 2) if discount_type == "percentage" else round(random.uniform(10, 50), 2)
    valid_from = random_date(START_DATE, END_DATE - timedelta(days=60))
    valid_to = valid_from + timedelta(days=random.randint(14, 90))
    promotions.append({
        "promo_id": promo_id,
        "code": f"{random.choice(PROMO_PREFIXES)}{random.randint(10, 99)}",
        "discount_type": discount_type,
        "discount_value": discount_value,
        "valid_from": valid_from,
        "valid_to": valid_to,
    })

# --- trips (the transactional core) ---
active_drivers = [d for d in drivers if d["status"] == "active"]
trips = []
for trip_id in range(1, NUM_TRIPS + 1):
    rider = random.choice(riders)
    driver = random.choice(active_drivers)
    vehicle = vehicle_by_driver[driver["driver_id"]]
    vtype = vehicle_type_by_id[vehicle["type_id"]]

    pickup_time = random_datetime_between(
        max(START_DATE, driver["signup_date"]),
        END_DATE,
    )
    pickup_city_id = driver["home_city_id"]
    # cross-city trips are common enough in Greater Cairo to model explicitly
    pickup_city_name = CITIES[pickup_city_id - 1]
    if pickup_city_name in METRO_CITIES and random.random() < 0.25:
        dropoff_city_id = city_id_by_name[random.choice(list(METRO_CITIES))]
    else:
        dropoff_city_id = pickup_city_id

    distance_km = round(random.uniform(1.5, 35.0), 2)
    trip_minutes = max(4, int(distance_km * random.uniform(1.8, 3.2)))
    dropoff_time = pickup_time + timedelta(minutes=trip_minutes)

    surge_multiplier = weighted_choice([1.0, 1.2, 1.5, 2.0], [0.70, 0.18, 0.09, 0.03])
    fare_amount = round((vtype["base_fare"] + vtype["per_km_rate"] * distance_km) * surge_multiplier, 2)

    status = weighted_choice(TRIP_STATUSES, TRIP_STATUS_WEIGHTS)
    promo_id = None
    if status == "completed" and random.random() < 0.18:
        eligible_promos = [p for p in promotions if p["valid_from"] <= pickup_time.date() <= p["valid_to"]]
        if eligible_promos:
            promo = random.choice(eligible_promos)
            promo_id = promo["promo_id"]
            if promo["discount_type"] == "percentage":
                fare_amount = round(fare_amount * (1 - promo["discount_value"] / 100), 2)
            else:
                fare_amount = round(max(0, fare_amount - promo["discount_value"]), 2)

    if status != "completed":
        dropoff_time_val = None
        distance_km_val = distance_km if status == "cancelled" else 0.0
    else:
        dropoff_time_val = dropoff_time
        distance_km_val = distance_km

    trips.append({
        "trip_id": trip_id,
        "rider_id": rider["rider_id"],
        "driver_id": driver["driver_id"],
        "vehicle_id": vehicle["vehicle_id"],
        "pickup_city_id": pickup_city_id,
        "dropoff_city_id": dropoff_city_id,
        "promo_id": promo_id,
        "pickup_time": pickup_time,
        "dropoff_time": dropoff_time_val,
        "distance_km": distance_km_val,
        "fare_amount": fare_amount if status == "completed" else 0.0,
        "surge_multiplier": surge_multiplier,
        "payment_method": weighted_choice(PAYMENT_METHODS, PAYMENT_METHOD_WEIGHTS),
        "status": status,
    })

# --- ratings (independent rider-side and driver-side ratings on completed trips) ---
ratings = []
rating_id = 1
completed_trips = [t for t in trips if t["status"] == "completed"]
for trip in completed_trips:
    if random.random() < 0.70:
        stars = weighted_choice([5, 4, 3, 2, 1], [0.50, 0.30, 0.12, 0.05, 0.03])
        ratings.append({
            "rating_id": rating_id,
            "trip_id": trip["trip_id"],
            "rated_by": "rider",
            "rating": stars,
            "comment": "Great ride, thanks!" if stars >= 4 and random.random() < 0.5 else None,
        })
        rating_id += 1
    if random.random() < 0.45:
        stars = weighted_choice([5, 4, 3, 2, 1], [0.55, 0.28, 0.10, 0.04, 0.03])
        ratings.append({
            "rating_id": rating_id,
            "trip_id": trip["trip_id"],
            "rated_by": "driver",
            "rating": stars,
            "comment": "Polite rider." if stars >= 4 and random.random() < 0.3 else None,
        })
        rating_id += 1


# ============================================================
# SQLite emission
# ============================================================

SCHEMA = """
CREATE TABLE cities (
    city_id INTEGER PRIMARY KEY,
    city_name TEXT NOT NULL
);
CREATE TABLE drivers (
    driver_id INTEGER PRIMARY KEY,
    driver_name TEXT NOT NULL,
    home_city_id INTEGER NOT NULL,
    signup_date TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (home_city_id) REFERENCES cities(city_id)
);
CREATE TABLE riders (
    rider_id INTEGER PRIMARY KEY,
    rider_name TEXT NOT NULL,
    city_id INTEGER NOT NULL,
    signup_date TEXT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);
CREATE TABLE driver_city_coverage (
    driver_id INTEGER NOT NULL,
    city_id INTEGER NOT NULL,
    PRIMARY KEY (driver_id, city_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);
CREATE TABLE vehicle_types (
    type_id INTEGER PRIMARY KEY,
    type_name TEXT NOT NULL,
    base_fare REAL NOT NULL,
    per_km_rate REAL NOT NULL
);
CREATE TABLE vehicles (
    vehicle_id INTEGER PRIMARY KEY,
    driver_id INTEGER NOT NULL UNIQUE,
    type_id INTEGER NOT NULL,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    plate_number TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (type_id) REFERENCES vehicle_types(type_id)
);
CREATE TABLE promotions (
    promo_id INTEGER PRIMARY KEY,
    code TEXT NOT NULL,
    discount_type TEXT NOT NULL,
    discount_value REAL NOT NULL,
    valid_from TEXT NOT NULL,
    valid_to TEXT NOT NULL
);
CREATE TABLE trips (
    trip_id INTEGER PRIMARY KEY,
    rider_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    pickup_city_id INTEGER NOT NULL,
    dropoff_city_id INTEGER NOT NULL,
    promo_id INTEGER NULL,
    pickup_time TEXT NOT NULL,
    dropoff_time TEXT NULL,
    distance_km REAL NOT NULL,
    fare_amount REAL NOT NULL,
    surge_multiplier REAL NOT NULL,
    payment_method TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (pickup_city_id) REFERENCES cities(city_id),
    FOREIGN KEY (dropoff_city_id) REFERENCES cities(city_id),
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id)
);
CREATE TABLE ratings (
    rating_id INTEGER PRIMARY KEY,
    trip_id INTEGER NOT NULL,
    rated_by TEXT NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NULL,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id)
);
"""


def iso(value):
    if value is None:
        return None
    if isinstance(value, (date, datetime)):
        return value.isoformat(sep=" ") if isinstance(value, datetime) else value.isoformat()
    return value


def insert_rows(conn, table, columns, rows):
    if not rows:
        return
    placeholders = ", ".join("?" for _ in columns)
    sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
    values = [tuple(iso(row[col]) for col in columns) for row in rows]
    conn.executemany(sql, values)


def build_db():
    if os.path.exists(OUT_PATH):
        os.remove(OUT_PATH)
    conn = sqlite3.connect(OUT_PATH)
    conn.executescript(SCHEMA)

    insert_rows(conn, "cities", ["city_id", "city_name"], cities)
    insert_rows(conn, "drivers", ["driver_id", "driver_name", "home_city_id", "signup_date", "status"], drivers)
    insert_rows(conn, "riders", ["rider_id", "rider_name", "city_id", "signup_date"], riders)
    insert_rows(conn, "driver_city_coverage", ["driver_id", "city_id"], driver_city_coverage)
    insert_rows(conn, "vehicle_types", ["type_id", "type_name", "base_fare", "per_km_rate"], vehicle_types)
    insert_rows(conn, "vehicles", ["vehicle_id", "driver_id", "type_id", "make", "model", "year", "plate_number"], vehicles)
    insert_rows(conn, "promotions", ["promo_id", "code", "discount_type", "discount_value", "valid_from", "valid_to"], promotions)
    insert_rows(conn, "trips", [
        "trip_id", "rider_id", "driver_id", "vehicle_id", "pickup_city_id", "dropoff_city_id",
        "promo_id", "pickup_time", "dropoff_time", "distance_km", "fare_amount",
        "surge_multiplier", "payment_method", "status",
    ], trips)
    insert_rows(conn, "ratings", ["rating_id", "trip_id", "rated_by", "rating", "comment"], ratings)

    conn.commit()
    conn.close()


def main():
    build_db()
    print(f"wrote {OUT_PATH}")
    print(f"  cities={len(cities)} drivers={len(drivers)} riders={len(riders)} "
          f"driver_city_coverage={len(driver_city_coverage)}")
    print(f"  vehicle_types={len(vehicle_types)} vehicles={len(vehicles)} promotions={len(promotions)}")
    print(f"  trips={len(trips)} ratings={len(ratings)}")


if __name__ == "__main__":
    main()
