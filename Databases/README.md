# Databases

Every database this course uses lives here — the MySQL provisioning script for the core lesson
days, and every project day's SQLite file. Some need a step before you start that day (run a
script, download a file); others are already here, ready to use.

| File | Creates | Used by | Before you start |
|---|---|---|---|
| `rawaj_db.sql` | `rawaj` (MySQL) — a fictional Egyptian e-commerce marketplace (14 tables: customers, sellers, products, orders, and more) | Days 01–05 | Run it once against your MySQL server |
| `rawaj.sqlite` | A SQLite copy of `rawaj` | Day 06 | Nothing — created by running `day06_python_sqlite.ipynb` itself |
| `wasel.sqlite` | A fictional Egyptian ride-hailing app (cities, drivers, riders, vehicles, trips, ratings, and more) | Day 07 | Nothing — already included in this repo |
| `soccer.sqlite` | European Soccer (players, teams, matches, betting odds) | Day 08 | Download it from Kaggle (~299 MB, over GitHub's 100 MB limit — see `Day 08/day08_reading.html`) |

`rawaj_db.sql` is idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run,
and declares real `PRIMARY KEY`/`FOREIGN KEY`/`UNIQUE` constraints.

Any new database a later day introduces goes here too, not inside that day's own folder.
