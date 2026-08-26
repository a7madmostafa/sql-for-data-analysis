# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A 9-day self-paced MySQL / SQL-for-Data-Analysis course (see `COURSE_PLAN.md` for the full build plan and source-material provenance, and `README.md` for the day-by-day table of contents). It is not an application — there is no build, lint, or test tooling. The contents are `.sql` scripts and notebooks (seed data + teaching queries + practice exercises), Markdown reading material, slide decks, and one Mermaid ER diagram embedded in a `.md` file.

Each lesson day (`Day 01`–`Day 05`) follows the same layout, subfolders ordered by a `D0N_0M_` prefix
so they list in read order: `D0N_01_Materials/` (a `day0N_reading.md` conceptual write-up plus the
`.pptx` slide deck and its `build.py` generator, built via the shared `_slide_kit/deckkit.py`),
`D0N_02_Walkthrough/` (the explained, titled SQL or notebook), `D0N_03_Exercises/`
(`day0N_exercises.sql` + `day0N_exercises_solutions.sql`, business-framed, numbered `N.M` to match
the walkthrough's section numbers). Project days (`Day 06`–`Day 09`) instead get a `Reading_0N.md`,
a `project_0N.ipynb`, and a `Data_0N.md` pointing to the (uncommitted) dataset source. Every file
inside a day's subfolders is prefixed `day0N_` so it stays unambiguous outside its folder (e.g. an
editor tab bar showing files from multiple days at once) — this convention started with Day 01 and
applies going forward. `OLD SQL/` and `Updated MySQL Tutorial/` are archived reference material,
excluded from git via `.gitignore` — treat them as read-only source material, not something to edit
or ship.

## Structure

- `Day 01/` — intro module using the sample **`world`** database (`city`, `country`, `countrylanguage` tables: cities, countries, and languages spoken per country).
  - `D01_01_Materials/` — `world_db.sql` (full `CREATE DATABASE world` + schema + seed data dump —
    run this first to provision the database), `day01_reading.md` (hands-on syntax write-up, with
    Mermaid/ASCII diagrams; conceptual material lives in the deck instead of being duplicated here),
    `Day 01 - SQL Foundations.pptx` (concepts + hands-on slide deck), `build.py` (regenerates the
    `.pptx` — see `_slide_kit/README.md`).
  - `D01_02_Walkthrough/day01_sql_foundations.sql` — annotated walkthrough queries, organized into numbered `-- SECTION N — TOPIC` blocks (exploring the server, SELECT, LIMIT/OFFSET, DISTINCT, aggregation/COUNT, ORDER BY) against `world`.
  - `D01_03_Exercises/` — `day01_exercises.sql` (business-framed practice questions numbered `N.M`) and `day01_exercises_solutions.sql` (matching answer key).
- `_slide_kit/` — shared `.pptx` builder (`deckkit.py`) used by every day's `D0N_01_Materials/build.py`, plus a `README.md` documenting its API, the reference-deck fonts (Bricolage Grotesque / Nunito Sans / IBM Plex Mono, installed per-user), and how to render preview PNGs via PowerPoint COM automation.
- `SQL 02/` — the **Parch & Posey** module, a fictional paper-sales company (from Udacity's SQL for Data Analysis course, adapted for MySQL here). *(Not yet renamed to `Day 02` or restructured onto the Day 01 convention — pending.)* Split into purpose-named subfolders:
  - `Database_Creation/` — `Parch & Posey Database.sql` (MySQL `CREATE DATABASE parch_and_posey` + schema + seed data, ~16k lines, mostly `INSERT` statements — run this first for this module) and `Parch & Posey Database (SQL Server).sql` (same dataset ported to T-SQL/SQL Server dialect; keep both in sync if the dataset changes, and don't assume MySQL syntax works in the latter).
  - `Database_Description/` — `Parch_and_Posey.md` (schema reference: table relationships and a Mermaid ERDiagram — region → sales_reps → accounts → {orders, web_events}; read this before writing queries against the dataset) and `parch_and_posey_erd.svg` (the rendered diagram it embeds).
  - `Live_Session_02/` — `sql_for_beginners.sql`, the teaching script, organized into numbered `-- SECTION N — TOPIC` blocks (LIMIT/OFFSET, DISTINCT, ORDER BY, aggregation, WHERE, AND/OR, BETWEEN, IN vs OR, NULL checks, LIKE, GROUP BY, DATE functions). New teaching content should follow this same section-header convention.
  - `Exercises_02/` — `exercises.sql` (practice questions mirroring the sections in `sql_for_beginners.sql`, numbered `N.M`, answer space left blank under each prompt) and `exercises_solutions.sql` (reference answers keyed to the same `N.M` numbering).

## Working with this repo

- To run any script: load it into a MySQL client (MySQL Shell/Workbench, `mysql` CLI, or the VS Code MySQL extension) pointed at a local MySQL server. There's no connection config checked in — connection details are supplied by whatever client opens the file.
- The two schema/seed files (`world_db.sql`, `Database_Creation/Parch & Posey Database.sql`) are idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run.
- Exercises reference tables by name only (`region, sales_reps, accounts, orders, web_events` / `city, country, countrylanguage`); the corresponding database script must be run first or the table won't exist.
- When adding a new exercise, keep the day's `D0N_03_Exercises/*_exercises.sql`, `D0N_03_Exercises/*_exercises_solutions.sql`, and `D0N_02_Walkthrough/*` walkthrough file numbered consistently — the solution file's section/question numbers must match the exercise file's.
- To regenerate a day's slide deck after editing its `build.py`: run it with the same Python environment `_slide_kit` was built against (needs `python-pptx`; PowerPoint must be closed if the target `.pptx` is currently open, or the save will fail with a permission error).
