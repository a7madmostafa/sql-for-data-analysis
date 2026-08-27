# SQL for Data Analysis — Self-Paced Course

A 9-day self-paced MySQL course: five days of core SQL syntax and Python connectivity, followed by
four applied projects on real datasets. See [`COURSE_PLAN.md`](COURSE_PLAN.md) for the full build
plan and source-material notes.

Each lesson day (01–05) contains:
- `D0N_01_Materials/` — the day's database-setup script and a single self-contained
  `day0N_reading.html` (concepts, diagrams, worked examples, gotchas — open it directly in a
  browser, no server needed)
- `D0N_02_Walkthrough/` — the explained, titled SQL (or notebook) to run alongside the reading
- `D0N_03_Exercises/` — practice questions (`day0N_exercises.sql`) and a reference answer key
  (`day0N_exercises_solutions.sql`)

Subfolders are numbered so they list in read order; every file inside them is prefixed `day0N_` so
it's unambiguous even outside its folder.

Each project day (06–09) contains a `Reading_0N.md` (business framing), a `project_0N.ipynb`
notebook, and a `Data_0N.md` pointing to the dataset source.

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

Each MySQL-backed day expects a local MySQL server. Run the relevant database script once before
starting that day (`Day 01/D01_01_Materials/world_db.sql` for Day 01; `Day 02/D02_01_Materials/
Parch & Posey Database.sql` for Days 02–05). From Day 05 onward you'll also need Python packages
listed in `requirements.txt` and a `.env` file (see `.env.example`) holding your local MySQL
credentials.
