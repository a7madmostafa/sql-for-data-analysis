# Databases

Shared database-provisioning scripts for the MySQL-backed lesson days. Run the relevant script
once against your local MySQL server before starting that day.

| File | Creates | Used by |
|---|---|---|
| `rawaj_db.sql` | `rawaj` — a fictional Egyptian e-commerce marketplace (14 tables: customers, sellers, products, orders, and more) | Days 01–05 |

The script is idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run. It
also declares real `PRIMARY KEY`/`FOREIGN KEY`/`UNIQUE` constraints.

Any new database introduced by a later lesson day goes here too, not inside that day's own folder.
