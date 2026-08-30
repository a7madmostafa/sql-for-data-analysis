# Day 07 — Project: European Soccer

The second applied project day. You're helping a recruitment analyst at a Championship football
club prepare for the January transfer window — twenty real questions about players, teams, and
leagues, JOIN- and view-heavy, answered against a real 7-table SQLite dataset. No new SQL syntax —
everything here is Days 01-04.

Like Day 06, this day needs no MySQL server and no `.env` file — everything runs against a local
SQLite file.

## What you'll learn

- Build a `CREATE VIEW` around a window function so "current rating per player" is defined once and
  reused across a dozen questions — Day 04's Views and window-function sections, working together
  for real.
- Recognize a SQLite-only convenience (the bare-column `MAX()` guarantee) and choose the portable
  pattern instead, because it's what actually works on MySQL too.
- Chain a 3-4 table JOIN through two views without rewriting the join logic each time.
- Combine a team's home and away results into one column with `UNION ALL` before aggregating.
- Turn a correlation into an actual business caveat, not just a chart.
- Spot a data-coverage gap with an anti-join before it becomes an unanswerable question from a
  stakeholder.

## Files

| File | What it is |
|---|---|
| `day07_reading.html` | Start here — the business case, the dataset (including how to download it — it's not committed to this repo), and all 20 questions. Open directly in a browser. |
| `project_07.ipynb` | The working notebook — all 20 questions, worked in order. |

## Before you start

1. **Dataset:** `day07_reading.html` has the download link and instructions for `soccer.sqlite`
   (~299 MB, from Kaggle) — place it at `Databases/soccer.sqlite`, alongside every other database
   this course uses. It's git-ignored — there's nothing to commit, just download it once.
2. **Python packages:** from the repo root, `pip install -r requirements.txt` if you haven't
   already — this day runs every query through jupysql's `%sql`/`%%sql` magic, plus `pandas` and
   `matplotlib` for the charts. No MySQL server or `.env` needed.
3. **Launch:** `jupyter notebook` from the repo root, then open `Day 07/project_07.ipynb`.

**Order:** `day07_reading.html` → `project_07.ipynb`.
