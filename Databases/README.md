# Databases

Every database this 7-day course uses lives here — the MySQL provisioning script for the core
lesson days, and every project day's SQLite file. Some need a step before you start that day (run
a script); others are already here, ready to use.

| File | Creates | Used by | Before you start |
|---|---|---|---|
| `rawaj_db.sql` | `rawaj` (MySQL) — a fictional Egyptian e-commerce marketplace (14 tables: customers, sellers, products, orders, and more) | Days 01–05 | Run it once against your MySQL server |
| `rawaj.sqlite` | A SQLite copy of `rawaj` | Day 06 | Nothing — created by running `day06_python_sqlite.ipynb` itself |
| `wasel.sqlite` | A fictional Egyptian ride-hailing app (cities, drivers, riders, vehicles, trips, ratings, and more) | Day 07 | Nothing — already included in this repo |
| `rawaj_schema.md` | Full column-level reference and ERD for `rawaj` | Days 01–06 | Nothing — reference only, read it anytime |
| `wasel_schema.md` | Full column-level reference and ERD for `wasel` | Day 07 | Nothing — reference only, read it anytime |

`rawaj_db.sql` is idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run,
and declares real `PRIMARY KEY`/`FOREIGN KEY`/`UNIQUE` constraints.
