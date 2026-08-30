# SQL for Data Analysis — Self-Paced Course

A 10-day self-paced course: five days of core SQL syntax, one day of Python connectivity, followed
by four applied projects on real datasets.

`Databases/` holds the shared database-provisioning scripts for every MySQL-backed day — run the
relevant one once before starting that day.

Each lesson day (01–05) is one flat folder — no subfolders, every file already prefixed `day0N_` so
it's unambiguous even outside its folder — containing:
- a single self-contained `day0N_reading.html` (concepts, diagrams, worked examples, gotchas — open
  it directly in a browser, no server needed) — start here
- the explained, titled SQL walkthrough (or notebook) to run alongside the reading
- practice questions (`day0N_exercises.sql`) and a reference answer key
  (`day0N_exercises_solutions.sql`)
- a `README.md` indexing that day's files, what you'll learn, and the order to work through them

Day 06 is a Python-connectivity bridge day — `day06_reading.html`, plus `.ipynb` notebooks instead
of `.sql` files: no new SQL, everything from Days 01–05 reached from Python, first a quick MySQL
sanity check, then real depth against a migrated SQLite copy.

Each project day (07–10) contains:
- `day0N_reading.html` (the business case, the dataset — including where to get it, since none of
  these are committed — and the full question list, same format as the lesson days above)
- `project_0N.ipynb` (the working notebook, run through jupysql's `%sql`/`%%sql` magic from Day 06)

## Table of Contents

| Day | Topic | Database | Status |
|---|---|---|---|
| [01](Day%2001) | SQL Foundations — SELECT, LIMIT/OFFSET, DISTINCT, ORDER BY, COUNT | `rawaj` (MySQL) | done |
| [02](Day%2002) | WHERE, operators, BETWEEN, IN, NULL, LIKE, GROUP BY, aggregates, DATE functions | `rawaj` (MySQL) | done |
| [03](Day%2003) | JOINs (INNER/multi-table/HAVING/LEFT/RIGHT/UNION) + CASE + String Functions | `rawaj` (MySQL) | done |
| [04](Day%2004) | Subqueries, CTEs, Temp Tables & Views | `rawaj` (MySQL) | done |
| [05](Day%2005) | Window Functions & Stored Procedures | `rawaj` (MySQL) | done |
| [06](Day%2006) | Python Connectivity — MySQL & SQLite | `rawaj` (MySQL) + SQLite | done |
| [07](Day%2007) | Project: Wasel — full Days 01-05 sweep, anti-joins, views, temp tables, window functions | Wasel dataset (SQLite) | done |
| [08](Day%2008) | Project: European Soccer — JOIN/VIEW-heavy walkthrough | Soccer dataset (SQLite) | done |
| 09 | Project: FitBit / Bellabeat — CTE-heavy, date/string mechanics | FitBit dataset (SQLite) | planned |
| 10 | Project: World Development Indicators — capstone, window functions | WDI dataset (SQLite) | planned |

## Setup

- Each MySQL-backed day expects a local MySQL server.
- Run the relevant database script once before starting that day:
  - `Databases/rawaj_db.sql` for Days 01–05
- From Day 06 onward you'll also need:
  - Python packages listed in `requirements.txt`
  - a `.env` file (see `.env.example`) holding your local MySQL password
