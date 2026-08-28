# Day 06 — Project: NBA

The first of four applied project days. You're helping an editor at a sports-media outlet put
together an NBA season-preview feature — twenty real questions about draft trends and franchise
history, answered against a real, 16-table SQLite dataset instead of the familiar
`parch_and_posey`/`world` databases. No new SQL syntax — everything here is Days 01-04.

This is also the first day that needs no MySQL server and no `.env` file — everything here runs
against a local SQLite file.

## What you'll learn

- Read and orient yourself in an unfamiliar 16-table schema before writing a single query.
- Answer real business questions with filtering, aggregation, and every JOIN shape from Day 03 —
  including the anti-join pattern — applied to data that wasn't pre-shaped for these exact
  questions.
- Bucket dates with SQLite's `STRFTIME()` (by year, decade, month) — the SQLite counterpart to
  MySQL's `DATE_FORMAT()`.
- Sanity-check a surprising query result instead of reporting it at face value — twice in this
  project, the obvious query is quietly wrong.
- Turn a query result into a quick chart with `pandas.plot()`, reached through jupysql's `%%sql`
  magic from Day 05.

## Files

| File | What it is |
|---|---|
| `day06_reading.html` | Start here — the business case, the dataset (including how to download it — it's not committed to this repo), and all 20 questions. Open directly in a browser. |
| `project_06.ipynb` | The working notebook — all 20 questions, worked in order. |

## Before you start

1. **Dataset:** `day06_reading.html` has the download link and instructions for `nba.sqlite`
   (~2.3 GB, from Kaggle) — place it at `Day 06/nba.sqlite`. It's git-ignored — there's nothing to
   commit, just download it once.
2. **Python packages:** from the repo root, `pip install -r requirements.txt` if you haven't
   already — this day runs every query through jupysql's `%sql`/`%%sql` magic (same as
   `day05_python_sqlite.ipynb`), plus `pandas` and `matplotlib` for the charts. No MySQL server or
   `.env` needed.
3. **Launch:** `jupyter notebook` from the repo root, then open `Day 06/project_06.ipynb`.

**Order:** `day06_reading.html` → `project_06.ipynb`.
