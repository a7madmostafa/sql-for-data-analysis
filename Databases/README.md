# Databases

Shared database-provisioning scripts for the MySQL-backed lesson days (01–05). Run the relevant
script once against your local MySQL server before starting that day.

| File | Creates | Used by |
|---|---|---|
| `world_db.sql` | `world` (`country`, `city`, `countrylanguage`) | Day 01 |
| `Parch & Posey Database.sql` | `parch_and_posey` (`region`, `sales_reps`, `accounts`, `orders`, `web_events`) | Days 02–05 |

Both scripts are idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run.
Any new database introduced by a later lesson day goes here too, not inside that day's own folder.
