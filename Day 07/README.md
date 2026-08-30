# Day 07 — Project: Wasel

The first applied project day. You're helping an operations analyst at Wasel, a fictional
Egyptian ride-hailing app, decide where to spend next quarter's driver-incentive budget — twenty
real questions about drivers, riders, and trips, covering every technique from Days 01-05. No new
SQL syntax — everything here is Days 01-05 (filtering, aggregation, JOINs, CASE, anti-joins,
subqueries, CTEs, views, temp tables, window functions), applied to a schema that wasn't built
with these exact questions in mind.

Like Day 06, this day needs no MySQL server and no `.env` file — everything runs against a local
SQLite file.

## What you'll learn

- Apply every Day 01-05 technique to a fresh schema (cities, drivers, riders, vehicles, trips,
  ratings) that wasn't built with these exact questions in mind.
- Spot a driver-supply gap with an anti-join, then confirm with a second query whether it's a real
  demand problem or a data problem.
- Save a "top drivers by earnings" view and reuse it across later questions instead of repeating
  the JOIN chain.
- Materialize a temp table once, then pull two different breakdowns from it without re-running the
  same filter twice.
- Rank drivers within their own city with `RANK()`, and see exactly how it handles a real 3-way
  tie.

## Files

| File | What it is |
|---|---|
| `day07_reading.html` | Start here — the business case, the dataset, and all 20 questions. Open directly in a browser. |
| `project_07.ipynb` | The working notebook — all 20 questions, worked in order. |
| `project_07.html` | The same notebook, already run — every question plus its real output, rendered as a page. No Jupyter needed; open it to check your own output against. |

## Before you start

1. **Dataset:** run `python _tools/generate_wasel_db.py` once from the repo root — it writes
   `Databases/wasel.sqlite` directly (generated, not downloaded; a fixed random seed makes it
   reproducible). Nothing to commit — it's git-ignored, just regenerate it if you ever lose the
   file.
2. **Python packages:** from the repo root, `pip install -r requirements.txt` if you haven't
   already — this day runs every query through jupysql's `%sql`/`%%sql` magic, plus `pandas` and
   `matplotlib` for the charts. No MySQL server or `.env` needed.
3. **Launch:** `jupyter notebook` from the repo root, then open `Day 07/project_07.ipynb`.

**Order:** `day07_reading.html` → `project_07.ipynb`.
