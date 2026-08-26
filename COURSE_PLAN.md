# Self-Paced MySQL Course — Plan

Status: **DRAFT — not yet executed.** Nothing described below has been created, renamed, or deleted
yet. This file is the plan to review; once approved, execution happens as a separate pass.

## Goal

Turn the existing 2-day live-session material (`SQL 01`, `SQL 02`), the archived material in
`OLD SQL/`, and the newly-found `Updated MySQL Tutorial/` material into a **9-day** self-paced
course: reading + slides + explained SQL + exercises for the core syntax days, then four applied
projects that lean on Python↔MySQL/SQLite connectivity.

Core teaching (Days 1–5) stays on **MySQL** against a local server; Day 05 also covers connecting
to *both* MySQL and SQLite from Python. Project days (6–9) run against **SQLite** `.sqlite` files,
so they work unmodified whether the student runs them on Kaggle or locally.

> Day count history: 8 → 9 (FitBit moved from "bonus" to a required project day) → 10 (Day 04 got
> too dense once `Updated MySQL Tutorial/` was added, split into Day 04 + Day 05) → **9** (Day 05
> and the Python-connection day merged back — Python connectivity is light content, no reason it
> needs its own day). If 9 is still too many, the lever to pull is merging two project days, not
> shrinking Days 1–5.

## New source: `Updated MySQL Tutorial/`

A separate, more polished tutorial series surfaced after the last plan draft — it materially
changes what backs Days 03–05:

- `1- Basics/SQL Basics.ipynb` — full single-table fundamentals (through `HAVING`) on a tiny 2-table
  demo DB. Polished, but **not used** — Days 01–02 already cover this ground on `world`/
  `parch_and_posey` and are already built. Its 25-question `SQL Basics Practice (Answers).ipynb`
  (WHERE/LIKE/IN/BETWEEN/ORDER BY on `parch_and_posey`) is optional supplemental exercise material
  for Day 02, not required.
- `2- Intermediate/SQL Intermediate.ipynb` — JOINs (INNER/LEFT/RIGHT/FULL-via-UNION, aliasing) +
  CASE + string functions + date functions, all on `parch_and_posey`. **Becomes the primary source
  for Day 03** (JOINs + CASE) and part of Day 04 (string functions); its date-function section is
  redundant with Day 02 and gets skipped. Ships with 6 embedded exercises plus a separate
  `SQL Intermediate Practice.ipynb` (10 blank JOIN questions) and its `(Answers)` sibling (same 10 +
  7 more covering CASE/date grouping) — good Day 03 exercise material.
- `3- Advanced/SQL Advanced.ipynb` — Subqueries, CTEs, and **Temp Tables** (new topic, not
  previously planned) are well-developed here. Its Views and Stored Procedures sections are empty
  placeholders, and window-function coverage is minimal (one `SUM() OVER (ORDER BY...)` running
  total, no `PARTITION BY`/`RANK`/`ROW_NUMBER`/`LAG`/`LEAD`). **Becomes the primary source for most
  of Day 04**; Views still comes from `OLD SQL/SQL_05/CTE and Views.sql`; Window Functions and
  Stored Procedures for Day 05 are written mostly fresh.
- `3- Advanced/string operations.sql` — `LTRIM`/`RTRIM`/`TRIM`/`LEFT`/`RIGHT`/`SUBSTRING`/`REPLACE`/
  `LOCATE`/`CONCAT`. Fills the string-functions gap directly.
- `1- Basics/Connection to Python.ipynb` — cleaner than the `OLD SQL` Python notebooks:
  `%sql`/`%%sql` magic, raw `mysql.connector`, and the canonical SQLAlchemy pattern. **Becomes the
  primary source for Day 05's Python half**, still needs the same retrofit as before (drop its small
  demo DB, use `parch_and_posey`, replace its hardcoded `password="0000"` with `.env`).
- Cosmetic note: this folder's demo DB is `employeedb` in the `.sql` script but `alextutorial` in
  the notebook — moot since neither is used going forward, but flagging so it isn't mistaken for a
  third distinct database.

## Course-wide conventions

- **Folder naming:** `SQL 01` → `Day 01`, `SQL 02` → `Day 02`, then `Day 03` … `Day 09`. Folder
  names carry no topic text — navigation comes from a root `README.md` table of contents instead.
- **File naming standard:** every file inside a day's subfolders is prefixed `day0N_` (e.g.
  `day01_reading.md`, `day01_exercises.sql`) so it stays unambiguous outside its folder — otherwise
  every day's exercises file would literally be named `exercises.sql`, indistinguishable in an
  editor's tab bar. Established with Day 01; apply to Day 02 (currently still `sql_for_beginners.sql`
  / `exercises.sql` / `exercises_solutions.sql`) when it's next touched.
- **Subfolder naming standard:** each day's subfolders are prefixed `D0N_0M_` (e.g. `D01_01_Materials`,
  `D01_02_Walkthrough`, `D01_03_Exercises`) so they list in read order in a plain file browser —
  established with Day 01, applies to Days 02–05 too.
- **Lesson-day layout** (Days 1–5), each folder gets:
  - `D0N_01_Materials/` — a `day0N_reading.md` write-up (concepts, worked examples, gotchas — read
    first) **and** the slide deck for the same material, kept together since they're consumed
    together: `Day 0N - Topic.pptx` plus the `build.py` that generates it (via the shared
    `_slide_kit/deckkit.py` — see its README for the builder API and font setup). The day's
    database-provisioning script (e.g. `world_db.sql`) also lives here. Where relevant, the reading
    calls out MySQL-vs-SQLite differences (e.g. `DATE_FORMAT` vs `STRFTIME`, `CONCAT()` vs `||`,
    `AUTO_INCREMENT` vs `AUTOINCREMENT`) — most relevant in Day 04 (string functions) and Day 05
    (dual connections), since Days 06–09 run on SQLite. Diagrams belong in both: Mermaid
    `erDiagram`/tables in the reading, native PowerPoint shapes (via `deckkit`'s entity/relationship/
    grid primitives) in the deck — same visual, appropriate to each medium.
  - `D0N_02_Walkthrough/` — the explained, titled SQL script (or notebook, for Day 5). Renamed from
    "Live_Session" — this is self-paced, nothing here is actually live.
  - `D0N_03_Exercises/` — `day0N_exercises.sql` + `day0N_exercises_solutions.sql`, business-framed,
    numbered `N.M` to match the walkthrough's section numbers (the pattern already used in Day 02,
    modulo the `day0N_` prefix)
- **Project-day layout** (Days 6–9), each folder gets:
  - `Reading_0N.md` — business framing + the question list for that project
  - `project_0N.ipynb` — the working notebook (adapted from the source notebooks below)
  - `Data_0N.md` — Kaggle source link + download instructions (data itself is **not** committed;
    the European Soccer `.sqlite` alone is 299 MB — same "link, don't commit" pattern the old
    material already used via `Kaggle Dataset.txt` / `data.docx` pointers)
- **Database reuse:** Day 01 keeps its own `world` setup. Day 02's `Database_Creation` /
  `Database_Description` (`parch_and_posey`) is shared by Days 02–05 — Days 03–05 don't duplicate
  it, their reading material just says "run Day 02's script first."
- **Root additions:** `README.md` (9-day table of contents), `.env.example` (MySQL credentials
  template for Day 05+), `requirements.txt` (Python packages used from Day 05 on).
- **Version control:** `git init` this directory as a repo. `.gitignore` excludes `OLD SQL/` and
  `Updated MySQL Tutorial/` (both stay on disk as local reference/archive, but untracked — not part
  of the published course history), `.env`, notebook checkpoints, `__pycache__`, and any downloaded
  project data files.

## Day-by-day

| Day | Topic | DB / Engine | Status |
|---|---|---|---|
| 01 | SQL Foundations — SELECT, LIMIT/OFFSET, DISTINCT, ORDER BY, COUNT | `world` (MySQL) | Retrofit existing |
| 02 | WHERE, operators, BETWEEN, IN, NULL, LIKE, GROUP BY, aggregates, DATE functions | `parch_and_posey` (MySQL) | Retrofit existing |
| 03 | JOINs — INNER, multi-table, GROUP BY + HAVING, LEFT/RIGHT OUTER, UNION — plus CASE | `parch_and_posey` (MySQL, shared) | New |
| 04 | String Functions, Subqueries, CTEs, Temp Tables, Views | `parch_and_posey` (MySQL, shared) | New |
| 05 | Window Functions, Stored Procedures, **and** connecting Python to MySQL/SQLite | `parch_and_posey` (MySQL) + SQLite basics | New |
| 06 | **Project: NBA** — draft/game/player analysis (easiest — thinnest technique spread) | NBA dataset (SQLite) | New |
| 07 | **Project: European Soccer** — JOIN/VIEW-heavy walkthrough | Soccer dataset (SQLite) | New |
| 08 | **Project: FitBit / Bellabeat** — CTE-heavy, SQLite date/string mechanics | FitBit dataset (SQLite) | New |
| 09 | **Project: World Development Indicators** — capstone, window functions in the wild (hardest, richest technique spread) | WDI dataset (SQLite) | New |

### Day 01 — SQL Foundations — DONE
- `D01_02_Walkthrough/day01_sql_foundations.sql` (renamed from `sql_basics.sql`) — every statement
  titled, organized into numbered sections.
- `D01_03_Exercises/day01_exercises.sql` + `day01_exercises_solutions.sql` — built from scratch (was
  missing entirely), business-framed, 18 questions + 2 challenges.
- `D01_01_Materials/` — `world_db.sql`, `day01_reading.md` (hands-on syntax, with a Mermaid ERD for
  `world` and an ASCII LIMIT/OFFSET diagram) plus `Day 01 - SQL Foundations.pptx` (19 slides:
  Concepts, condensed from `SQL for Data Analysis.pdf`, then Hands-On) and its `build.py`.
- Introduced `_slide_kit/deckkit.py`, the shared `.pptx` builder every later day's
  `D0N_01_Materials/build.py` will reuse — see `_slide_kit/README.md`.

### Day 02 — Filtering & Aggregation
- Already done in this session: `sql_for_beginners.sql` (every statement titled, bugs fixed) and
  its exercises (reordered to match the walkthrough, business-framed, harder, DATE-functions
  section added). *(Currently still on the old `Live_Session_02` / `Exercises_02` / `Slides_02`
  layout on disk — gets moved onto the `D02_01_Materials` / `D02_02_Walkthrough` /
  `D02_03_Exercises` + `day02_` file-prefix convention, matching Day 01, when next touched.)*
- Add: `day02_reading.md` inside `D02_01_Materials/`, plus the slide deck. Optionally fold in a few
  questions from `Updated MySQL Tutorial/1- Basics/SQL Basics Practice (Answers).ipynb` (25 Qs,
  WHERE/LIKE/IN/BETWEEN on `parch_and_posey`) if the exercises need more variety.

### Day 03 — JOINs + CASE
- Primary source: `Updated MySQL Tutorial/2- Intermediate/SQL Intermediate.ipynb` — its JOIN section
  (INNER implicit via `ON`, multi-table, aliasing, LEFT/LEFT OUTER, RIGHT/RIGHT OUTER, FULL emulated
  via `UNION`) and its CASE section.
- Supplement from `OLD SQL/SQL_03/02- Join_Statements.sql`: the HAVING-paired-with-JOIN examples and
  the anti-join pattern (`LEFT JOIN ... WHERE x.id IS NULL`) aren't in the new source and are worth
  keeping. `01- Practice.sql` still works as a Day 02 warm-up review. `SQL_01/many_to_many_example.md`
  (relationship primer) still opens `Reading_03.md`, ahead of JOIN syntax.
- Exercises: `Updated MySQL Tutorial/2- Intermediate/SQL Intermediate Practice.ipynb` (10 blank JOIN
  questions) plus its `(Answers)` sibling's extra Q11–17 (CASE-based tiering, month/year grouping) —
  good direct source for `Exercises_03`, reframed as business questions per this course's style.
- Note: `SQL 03/Join_Statements.sql` at the repo root is an unmodified copy of the *old* JOIN source,
  staged there before this new material surfaced — now secondary/supplementary rather than primary.
- Build: `Walkthrough_03`, `Exercises_03`, `Reading_03.md`, `Slides_03`.

### Day 04 — String Functions, Subqueries, CTEs, Temp Tables, Views
- String functions: `Updated MySQL Tutorial/3- Advanced/string operations.sql` (`LTRIM`/`RTRIM`/
  `TRIM`/`LEFT`/`RIGHT`/`SUBSTRING`/`REPLACE`/`LOCATE`/`CONCAT`) plus the string-cleaning section of
  `SQL Intermediate.ipynb` (`LOWER`/`UPPER`/`LENGTH`, `COALESCE`/`IFNULL`, a domain-extraction
  exercise).
- Subqueries, CTEs, Temp Tables: `Updated MySQL Tutorial/3- Advanced/SQL Advanced.ipynb` — row-tuple
  and derived-table subqueries, `WITH ... AS (...)` (including one nested-CTE example), 
  `CREATE TEMPORARY TABLE`, and a markdown comparison table (Subquery vs CTE vs Temp Table vs View)
  worth keeping close to verbatim in `Reading_04.md`.
- Views: `SQL Advanced.ipynb`'s Views section is an empty placeholder — use `OLD SQL/SQL_05/CTE and
  Views.sql` instead.
- Note: `SQL 03/Case.sql` and `SQL 03/Subquery and CTE.sql` at the repo root are unmodified copies of
  the *old* sources — Case.sql's content now belongs in Day 03, not here; Subquery-and-CTE.sql is
  superseded by `SQL Advanced.ipynb` as the primary source but can still supply extra examples.
- Build: `Walkthrough_04`, `Exercises_04`, `Reading_04.md`, `Slides_04`.

### Day 05 — Window Functions, Stored Procedures, and Python (MySQL + SQLite)
- Window functions and stored procedures are thin-to-empty in every available source:
  - Window functions: `SQL Advanced.ipynb` has exactly one pattern (`SUM(...) OVER (ORDER BY
    occurred_at)` running total) and its practice-answers file adds one `PARTITION BY` variant. The
    Day 09 project (`economic-indicators.ipynb`) uses `RANK() OVER (PARTITION BY ...)` but never
    explains it. **Written mostly fresh**: `OVER`, `PARTITION BY`, `ORDER BY` inside the window
    clause, `RANK`/`DENSE_RANK`/`ROW_NUMBER`, running totals/averages, `LAG`/`LEAD` — using the two
    existing examples as a starting point so Day 09 is applying a taught concept, not meeting it
    cold.
  - Stored procedures: `SQL Advanced.ipynb`'s section is an empty placeholder — **written fresh**:
    `CREATE PROCEDURE`, `DELIMITER` handling, `IN`/`OUT` parameters, `CALL`. Kept intentionally
    short — this is a data-analysis course, not a backend/app-dev one, so the goal is "know what
    this is and read one when you see it," not deep mastery.
  - Python connection (merged in from the former standalone day — light content, doesn't need its
    own day): primary source `Updated MySQL Tutorial/1- Basics/Connection to Python.ipynb` (cleaner
    than the `OLD SQL` equivalents), adapted — drop its small demo DB, use `parch_and_posey`
    throughout, replace its hardcoded `password="0000"` with `python-dotenv` + `.env`. `OLD SQL/
    SQL_03/For Python Notebooks/*` and `OLD SQL/SQL_04/Visualize.ipynb` remain useful secondary
    material, particularly for the `pandas.plot()` visualization pass. Covers **both** engines,
    since Days 06–09 all run on SQLite while Days 01–04 ran on MySQL:
    - MySQL: `mysql-connector-python`, a SQLAlchemy `mysql+mysqlconnector://` engine, credentials
      pulled from `.env` via `python-dotenv`
    - SQLite: the stdlib `sqlite3` module directly, plus a SQLAlchemy `sqlite:///` engine (no
      credentials needed — this is the exact pattern every project notebook uses)
    - Common to both: `pandas.read_sql`, Jupyter `%sql`/`%%sql` magic, and a first pass at
      `pandas.plot()` visualization
- Build: `Walkthrough_05` (a notebook, first day that isn't a `.sql` file — SQL-only content goes in
  the same notebook via `%sql`/`%%sql` cells so window functions/stored procedures and the Python
  connection material stay in one continuous walkthrough), `Exercises_05`, `Reading_05.md` (env
  setup: installs, creating `.env`, why secrets aren't committed, MySQL vs SQLite connection-string
  differences), `Slides_05`.
- Root additions this day introduces: `.env.example`, `requirements.txt`.
- **Density flag:** this is now three sub-topics in one day (window functions, stored procedures,
  Python/dual-engine connectivity) — each individually light, but worth a second look if Day 05 ends
  up feeling long in practice.

### Day 06 — Project: NBA
- Base: `OLD SQL/nba-analysis-using-sql.ipynb` (real executable SQLite SQL, but currently thin —
  no JOINs despite 16 available tables, no CTE/CASE/window functions, and it stops unfinished at
  question 7). Placed first because it's the easiest/thinnest of the four.
- To do during execution: finish the dangling section, and add 2–3 JOIN-based questions so this day
  reinforces Day 03.
- Discard as superseded: `OLD SQL/Project 2/historic-nba-drafting-game-and-player-analysis.ipynb`
  (the earlier, weaker draft of the same project).

### Day 07 — Project: European Soccer
- Base: `OLD SQL/soccer-data-analysis.ipynb` (multi-table JOINs, layered `CREATE VIEW`s, good
  reinforcement of Days 03–04).
- Discard: `OLD SQL/soccer-data-analysis-02.ipynb` (5-cell stub, no real content) and the older
  `OLD SQL/usecase - 1/data-analysis-using-sql.ipynb` / `OLD SQL/SQL_05/Use Case 01_European
  Soccer/soccer-data-analysis.ipynb` (superseded drafts of the same case study).

### Day 08 — Project: FitBit / Bellabeat
- Base: `OLD SQL/fitbit-sql-data-analysis.ipynb` — a strong, real SQLite rewrite of the Bellabeat
  case study: nested CTEs, SQLite-specific date/string mechanics (`STRFTIME`, `julianday()` for
  date-diffs since SQLite has no `DATEDIFF`, `INSTR`/`SUBSTR`/`printf` for date parsing). Good
  reinforcement of Day 04 (CTEs, string functions) and Day 05 (SQLite connections).
- To do during execution: finish the two empty trailing sections (Compare Minutes/Distances
  Categories) before publishing.
- Discard as superseded: `OLD SQL/usecase - 2/bellabeat-case-study-excel-sql-tableau.ipynb` (the
  non-executable BigQuery-text original this notebook replaces).

### Day 09 — Project: World Development Indicators
- Base: `OLD SQL/economic-indicators.ipynb` — richest of all the project notebooks: JOIN, VIEW,
  CASE, `EXISTS` subquery, and `RANK() OVER (PARTITION BY ...)` — now applying a technique Day 05
  already taught, rather than introducing it cold. Placed last as the hardest/richest capstone.
- Discard as superseded: `OLD SQL/Project 1/exploratory-data-analysis-with-sql.ipynb`.

## Open items to confirm before/at execution

1. ~~Exact slide-deck format~~ — resolved: real `.pptx` via a shared `_slide_kit/deckkit.py` builder,
   styled to match a reference deck (fonts installed locally), diagrams drawn as native PowerPoint
   shapes rather than embedded images (no image-generation capability available).
2. Day 03/04 file names for the rewritten `Walkthrough` SQL (placeholder names used above) — apply
   the `day0N_` prefix standard once named.
3. Whether to physically move/rename `SQL 03` (the staged root folder) into `Day 03` now, or treat
   it purely as scratch input and build `Day 03` fresh — its contents now span Day 03 (Case.sql →
   partially) and Day 04 (Subquery and CTE.sql) rather than mapping to one day.
4. How deep Day 05's Stored Procedures section should go, given it's written fresh with no source
   material — current plan is intentionally shallow ("recognize and read one," not "write complex
   ones").
5. Day 05's three-sub-topic density (see flag above) — confirm merging Python back in still feels
   right once the window-functions/stored-procedures content actually exists, or split again then.
