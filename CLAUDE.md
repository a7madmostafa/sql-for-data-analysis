# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Bootcamp course materials for a MySQL / SQL-for-Data-Analysis module. It is not an application — there is no build, lint, or test tooling. The contents are `.sql` scripts (seed data + teaching queries + practice exercises) and one Mermaid ER diagram embedded in a `.md` file.

## Structure

- `SQL 01/` — intro module using the sample **`world`** database (`city`, `country`, `countrylanguage` tables: cities, countries, and languages spoken per country). Flat folder, no subdirectories.
  - `world_db.sql` — full `CREATE DATABASE world` + schema + seed data dump. Run this first to provision the database.
  - `sql_basics.sql` — annotated walkthrough queries (SHOW DATABASES, DESCRIBE, SELECT/LIMIT/OFFSET/DISTINCT/ORDER BY/COUNT) against `world`.
- `SQL 02/` — the **Parch & Posey** module, a fictional paper-sales company (from Udacity's SQL for Data Analysis course, adapted for MySQL here). Split into purpose-named subfolders:
  - `Database_Creation/` — `Parch & Posey Database.sql` (MySQL `CREATE DATABASE parch_and_posey` + schema + seed data, ~16k lines, mostly `INSERT` statements — run this first for this module) and `Parch & Posey Database (SQL Server).sql` (same dataset ported to T-SQL/SQL Server dialect; keep both in sync if the dataset changes, and don't assume MySQL syntax works in the latter).
  - `Database_Description/` — `Parch_and_Posey.md` (schema reference: table relationships and a Mermaid ERDiagram — region → sales_reps → accounts → {orders, web_events}; read this before writing queries against the dataset) and `parch_and_posey_erd.svg` (the rendered diagram it embeds).
  - `Live_Session_02/` — `sql_for_beginners.sql`, the teaching script, organized into numbered `-- SECTION N — TOPIC` blocks (LIMIT/OFFSET, DISTINCT, ORDER BY, aggregation, WHERE, AND/OR, BETWEEN, IN vs OR, NULL checks, LIKE, GROUP BY, DATE functions). New teaching content should follow this same section-header convention.
  - `Exercises_02/` — `exercises.sql` (practice questions mirroring the sections in `sql_for_beginners.sql`, numbered `N.M`, answer space left blank under each prompt) and `exercises_solutions.sql` (reference answers keyed to the same `N.M` numbering).

## Working with this repo

- To run any script: load it into a MySQL client (MySQL Shell/Workbench, `mysql` CLI, or the VS Code MySQL extension) pointed at a local MySQL server. There's no connection config checked in — connection details are supplied by whatever client opens the file.
- The two schema/seed files (`world_db.sql`, `Database_Creation/Parch & Posey Database.sql`) are idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run.
- Exercises reference tables by name only (`region, sales_reps, accounts, orders, web_events` / `city, country, countrylanguage`); the corresponding database script must be run first or the table won't exist.
- When adding a new exercise, keep `Exercises_02/exercises.sql`, `Exercises_02/exercises_solutions.sql`, and `Live_Session_02/sql_for_beginners.sql` numbered consistently — the solution file's section/question numbers must match the exercise file's.
