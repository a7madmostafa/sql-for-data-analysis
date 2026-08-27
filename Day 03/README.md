# Day 03 — JOINs + CASE

Still on the **Parch & Posey** database from Day 02 (no new setup script here) — this is where all
five tables come together instead of being queried one at a time.

## What you'll learn

- Combine rows from multiple tables with `JOIN`, and know when a plain (INNER) `JOIN` silently drops rows you wanted.
- Keep unmatched rows with `LEFT`/`RIGHT JOIN`, and use that same pattern to write an anti-join.
- Emulate MySQL's missing `FULL JOIN` with `UNION`.
- Aggregate and filter across joined tables with `GROUP BY` and `HAVING`.
- Add conditional logic with `CASE` — labeling rows, and bucketing continuous values into tiers.

## Files

| File | What it is |
|---|---|
| `day03_reading.html` | Start here. Concepts, diagrams, and worked examples — open directly in a browser. |
| `day03_joins_and_case.sql` | The annotated walkthrough — run alongside the reading. |
| `day03_exercises.sql` | Practice questions, business-framed. Try these before looking at the solutions. |
| `day03_exercises_solutions.sql` | Answer key, numbered to match the exercises. |

**Before you start:** run `../Databases/Parch & Posey Database.sql` if you haven't already.

**Order:** `day03_reading.html` → `day03_joins_and_case.sql` → `day03_exercises.sql`.
