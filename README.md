# SQL for Data Analysis — Self-Paced Course

A 9-day self-paced MySQL course: five days of core SQL syntax and Python connectivity, followed by
four applied projects on real datasets.

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

Each project day (06–09) contains:
- `Reading_0N.md` (business framing)
- `project_0N.ipynb` (the working notebook)
- `Data_0N.md` (pointing to the dataset source)

## Table of Contents

| Day | Topic | Database | Status |
|---|---|---|---|
| [01](Day%2001) | SQL Foundations — SELECT, LIMIT/OFFSET, DISTINCT, ORDER BY, COUNT | `world` (MySQL) | done |
| [02](Day%2002) | WHERE, operators, BETWEEN, IN, NULL, LIKE, GROUP BY, aggregates, DATE functions | `parch_and_posey` (MySQL) | done |
| [03](Day%2003) | JOINs (INNER/multi-table/HAVING/LEFT/RIGHT/UNION) + CASE | `parch_and_posey` (MySQL) | done |
| 04 | String Functions, Subqueries, CTEs, Temp Tables, Views | `parch_and_posey` (MySQL) | planned |
| 05 | Window Functions, Stored Procedures, Python → MySQL & SQLite | `parch_and_posey` (MySQL) + SQLite | planned |
| 06 | Project: NBA — draft/game/player analysis | NBA dataset (SQLite) | planned |
| 07 | Project: European Soccer — JOIN/VIEW-heavy walkthrough | Soccer dataset (SQLite) | planned |
| 08 | Project: FitBit / Bellabeat — CTE-heavy, date/string mechanics | FitBit dataset (SQLite) | planned |
| 09 | Project: World Development Indicators — capstone, window functions | WDI dataset (SQLite) | planned |

## Setup

- Each MySQL-backed day expects a local MySQL server.
- Run the relevant database script once before starting that day:
  - `Databases/world_db.sql` for Day 01
  - `Databases/Parch & Posey Database.sql` for Days 02–05
- From Day 05 onward you'll also need:
  - Python packages listed in `requirements.txt`
  - a `.env` file (see `.env.example`) holding your local MySQL credentials
