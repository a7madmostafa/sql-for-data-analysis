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
- **Flat lesson-day folders, no subfolders:** each day is one flat folder. Days 01–03 originally used
  numbered subfolders (`D0N_01_Materials`, `D0N_02_Walkthrough`, `D0N_03_Exercises`, prefixed
  `D0N_0M_` so they'd list in read order in a plain file browser) — dropped once every file already
  carried a unique `day0N_` prefix, making the subfolder numbering redundant with the filename
  prefix. A per-day `README.md` (see below) now provides the "what order do I open these in"
  guidance the subfolders used to. Don't recreate subfolders for Day 04 onward.
- **Shared `Databases/` folder:** every MySQL database-provisioning script (`world_db.sql`, `Parch &
  Posey Database.sql`, and any future one) lives in a root-level `Databases/` folder, not inside the
  lesson day that first introduces it — `Parch & Posey Database.sql` alone is shared by Days 02–05,
  so keeping it inside `Day 02/` was misleading about ownership. Originally these scripts lived
  inside each day's own materials folder; moved out once that became clear.
- **Lesson-day layout** (Days 1–5), each flat folder gets:
  - a single self-contained `day0N_reading.html` (concepts, worked examples, gotchas, diagrams —
    open directly in a browser, no build step). **Format history:** Days 01–03
    originally shipped as a `day0N_reading.md` write-up plus a separately-built `.pptx` deck (via a
    shared `_slide_kit/deckkit.py` builder) — the user found maintaining two formats per day
    friction-prone and asked for one consolidated file instead. An HTML candidate and a
    consolidated-Markdown candidate were both prototyped side by side for Days 01–02; HTML won
    ("html is more rich"), then went through iteration on diagram richness, prose depth, and a
    code-block color-contrast bug before Days 01–03 were rebuilt as `day0N_reading.html` and the
    old `.md`/`.pptx`/`build.py`/`_slide_kit/` files were removed. See `CLAUDE.md`'s "Reading
    material format" section for the current design system and diagram rules — every diagram is
    hand-drawn inline SVG in one consistent crow's-foot "blueprint" style (white background + grid
    pattern, `#333` strokes, `#dfe3e8` headers, `#1f6fb2` titles, Segoe UI, no shadows); Mermaid was
    tried for ERDs first, then dropped in favor of this style once the user compared both — apply
    that to Day 04 onward, not the pptx approach described in older entries below.
    Where relevant, the reading calls out MySQL-vs-SQLite differences (e.g. `DATE_FORMAT` vs
    `STRFTIME`, `CONCAT()` vs `||`, `AUTO_INCREMENT` vs `AUTOINCREMENT`) — most relevant in Day 04
    (string functions) and Day 05 (dual connections), since Days 06–09 run on SQLite.
  - the explained, titled SQL walkthrough script (or notebook, for Day 5). Renamed from
    "Live_Session" — this is self-paced, nothing here is actually live.
  - `day0N_exercises.sql` + `day0N_exercises_solutions.sql`, business-framed, numbered `N.M` to
    match the walkthrough's section numbers (the pattern already used in Day 02, modulo the
    `day0N_` prefix)
  - `README.md` indexing that day's files, the order to work through them, and a "what you'll
    learn" summary mirroring the reading's own objectives list
- **Project-day layout** (Days 6–9), each folder gets:
  - `Reading_0N.md` — business framing + the question list for that project
  - `project_0N.ipynb` — the working notebook (adapted from the source notebooks below)
  - `Data_0N.md` — Kaggle source link + download instructions (data itself is **not** committed;
    the European Soccer `.sqlite` alone is 299 MB — same "link, don't commit" pattern the old
    material already used via `Kaggle Dataset.txt` / `data.docx` pointers)
  - `README.md`, same as lesson days
- **Database reuse:** Day 01 keeps its own `world` setup. Day 02's DB setup script
  (`parch_and_posey`) is shared by Days 02–05 — Days 03–05 don't duplicate it, their reading
  material just says "run Day 02's script first."
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
- **Superseded:** `day01_reading.md` + `Day 01 - SQL Foundations.pptx` + `build.py` were later
  replaced by a single `day01_reading.html` (see the format-history note above) — `_slide_kit/` is
  gone entirely, this entry is kept for provenance only. Subfolders (`D01_01_Materials/` etc.) were
  also later flattened away — see the "Flat lesson-day folders" convention above.

### Day 02 — Filtering & Aggregation — DONE
- Migrated onto the Day 01 convention: `D02_02_Walkthrough/day02_filtering_and_aggregation.sql`
  (every statement titled, bugs fixed, from earlier in this session) and
  `D02_03_Exercises/day02_exercises.sql` + `day02_exercises_solutions.sql` (reordered to match the
  walkthrough, business-framed, harder, DATE-functions section added).
- `D02_01_Materials/` — DB setup (`Parch & Posey Database.sql`; the SQL Server T-SQL variant that
  used to sit alongside it was dropped — this course is MySQL-only),
  `Parch_and_Posey.md` + `parch_and_posey_erd.svg` (detailed schema reference) and
  `dates_specifiers.jpg` (DATE_FORMAT chart) carried over from the old layout; `day02_reading.md`
  (new — Mermaid ERD for the region→sales_reps→accounts→{orders,web_events} chain, plus ASCII
  diagrams for AND/OR and GROUP BY) and `Day 02 - Filtering & Aggregation.pptx` (16 slides — new
  `chain_fork_slide` and `group_by_diagram_slide` diagram types added to `_slide_kit/deckkit.py`
  for this day's ERD shape and GROUP BY bucketing visual).
- Not folded in: the `Updated MySQL Tutorial/1- Basics/SQL Basics Practice (Answers).ipynb` bonus
  questions — exercises already had enough variety without them.
- **Superseded:** `day02_reading.md`/`Day 02 - Filtering & Aggregation.pptx`/`build.py` were later
  replaced by `day02_reading.html` — `dates_specifiers.jpg` was dropped too, replaced by an inline
  `DATE_FORMAT` specifier table in the HTML. `parch_and_posey_erd.svg`'s markup was copied directly
  into `day02_reading.html`'s dataset section (same crow's-foot style, kept as-is rather than
  redrawn) — once the schema lived in the reading itself, `Parch_and_Posey.md` and the standalone
  `parch_and_posey_erd.svg` were redundant and were deleted too. This entry is kept for provenance
  only. Subfolders (`D02_01_Materials/` etc.) were also later flattened away — see the "Flat
  lesson-day folders" convention above.

### Day 03 — JOINs + CASE — DONE
- Primary source: `Updated MySQL Tutorial/2- Intermediate/SQL Intermediate.ipynb` — its JOIN section
  (INNER implicit via `ON`, multi-table, aliasing, LEFT/LEFT OUTER, RIGHT/RIGHT OUTER, FULL emulated
  via `UNION`) and its CASE section, plus its `SQL Intermediate Practice.ipynb` (10 blank JOIN
  questions) and the `(Answers)` sibling's extra Q11–17 — reframed as business questions.
- Supplemented from `OLD SQL/SQL_03/02- Join_Statements.sql`: the HAVING-paired-with-JOIN examples
  and the anti-join pattern (`LEFT JOIN ... WHERE x.id IS NULL`), which weren't in the new source.
  `SQL_01/many_to_many_example.md`'s 1:1/1:N/N:N framing (already used in Day 01) is what
  `day03_reading.md` opens with, reframed as "a JOIN is how you follow a foreign key."
- Dropped: the sourced Q17 (find the top sales rep per region) needs a subquery/CTE — out of scope
  for Day 03. Reworked into challenge question C3 instead, using `COUNT(DISTINCT ...)` to solve a
  similar-shaped problem (reps who are both top performers AND manage several accounts) without a
  subquery, teaching the JOIN-fan-out-inflates-COUNT gotcha along the way.
- `D03_01_Materials/day03_reading.md` + `Day 03 - JOINs + CASE.pptx` (15 slides). One slide (LEFT
  JOIN row-matching) is built with raw `deckkit` primitives directly in `build.py` rather than a new
  named method — a one-off, not clearly reusable elsewhere yet.
- Bug fixed along the way (affects all three decks, all rebuilt): `cards_slide`'s card height was
  fixed regardless of description length, so a 3-line description overflowed into the next card.
  Now sized dynamically, same fix pattern already used for `code_slide`'s notes column.
- **Superseded:** `day03_reading.md` + `Day 03 - JOINs + CASE.pptx` + `build.py` were later replaced
  by `day03_reading.html`, applying the same design system as Days 01–02 (hand-drawn crow's-foot SVG
  for the N:N book/book_author/author relationship — Mermaid was used briefly here too before being
  dropped course-wide — and a hand-drawn SVG for the LEFT JOIN unmatched-row example, since it shows
  specific record instances rather than a table schema). This entry is kept for
  provenance only. Subfolders (`D03_01_Materials/` etc.) were also later flattened away — see the
  "Flat lesson-day folders" convention above.

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
- Build: `day04_reading.html` (see `CLAUDE.md`'s "Reading material format"), the walkthrough SQL,
  exercises + solutions, and a `README.md` — flat in `Day 04/`, no subfolders (see "Flat lesson-day
  folders" above).

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

1. ~~Exact slide-deck format~~ — resolved, then superseded: originally a real `.pptx` via a shared
   `_slide_kit/deckkit.py` builder; later replaced entirely by a single self-contained
   `day0N_reading.html` per day (Days 01–03 rebuilt, `_slide_kit/` removed) — see CLAUDE.md's
   "Reading material format" section. Diagrams are every one hand-drawn inline SVG in a consistent
   crow's-foot "blueprint" style (Mermaid was tried for ERDs first, then dropped course-wide once
   the user preferred a pre-existing hand-drawn asset's look) — still no raster image generation.
2. Day 03/04 file names for the rewritten `Walkthrough` SQL (placeholder names used above) — apply
   the `day0N_` prefix standard once named.
3. ~~Whether to move `SQL 03` (staged root folder) into `Day 03`~~ — resolved: built `Day 03` fresh
   from `OLD SQL/SQL_03/` directly (see Day 03's DONE entry), and confirmed `SQL 03/`'s contents
   were unmodified duplicates already archived under `OLD SQL/SQL_03/` and `OLD SQL/SQL_04/` — the
   root `SQL 03/` staging copy was removed as redundant scratch. Day 04 sources from
   `OLD SQL/SQL_04/` directly when it's built.
4. How deep Day 05's Stored Procedures section should go, given it's written fresh with no source
   material — current plan is intentionally shallow ("recognize and read one," not "write complex
   ones").
5. Day 05's three-sub-topic density (see flag above) — confirm merging Python back in still feels
   right once the window-functions/stored-procedures content actually exists, or split again then.
