# SQL for Data Analysis — Self-Paced Course

A 7-day self-paced course for complete beginners: five days of core SQL syntax, one day of Python
connectivity, and one applied project on an unfamiliar dataset. No prior SQL is assumed, and no
programming until Day 06.

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

Day 07 is the applied project day — `day07_reading.html` (the business case and the full question
list, same format as the lesson days above), `project_07_exercises.ipynb` (empty `%%sql` cells to
fill in yourself), and `project_07_solutions.ipynb` (the worked answer key), both run through
jupysql's `%sql`/`%%sql` magic from Day 06.

Every walkthrough `.sql` file and notebook also has a pre-rendered HTML twin (`day0N_*.html` /
`project_07_solutions.html`) — every statement plus its real output, already run, so you can read
a day's material without MySQL or Jupyter running yet.

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

## Setup

- Each MySQL-backed day expects a local MySQL server.
- Run the relevant database script once before starting that day:
  - `Databases/rawaj_db.sql` for Days 01–05
- Day 06 additionally needs:
  - Python packages listed in `requirements.txt`
  - a `.env` file (see `.env.example`) holding your local MySQL password — for its MySQL half only
- Day 07 needs neither a MySQL server nor `.env` — it runs entirely against a local SQLite file
  already included in the repo (just the Python packages above).
