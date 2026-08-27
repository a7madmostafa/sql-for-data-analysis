# Day 04 — String Functions, Subqueries, CTEs, Temp Tables & Views

Still on the **Parch & Posey** database from Days 02–03 (no new setup script here) — this is where
you start reshaping text and reusing query results instead of writing everything as one flat
statement.

## What you'll learn

- Trim, slice, and rebuild text with `LTRIM`/`RTRIM`/`TRIM`, `LEFT`/`RIGHT`/`SUBSTRING`/`LOCATE`,
  `CONCAT`, `REPLACE`, `LOWER`/`UPPER`/`LENGTH`.
- Fill in gaps left by a `CASE` expression with `COALESCE`/`IFNULL`.
- Write a scalar subquery (one value) and a row subquery (a tuple, matched with `IN`).
- Use a subquery as a derived table in `FROM`, then rewrite the same idea more readably with a CTE.
- Chain multiple CTEs together, and know when to reach for a temporary table or a view instead.
- Choose the right tool — subquery, CTE, temp table, or view — for a given reuse scenario.

## Files

| File | What it is |
|---|---|
| `day04_reading.html` | Start here. Concepts, diagrams, and worked examples — open directly in a browser. |
| `day04_string_functions_subqueries_ctes.sql` | The annotated walkthrough — run alongside the reading. |
| `day04_exercises.sql` | Practice questions, business-framed. Try these before looking at the solutions. |
| `day04_exercises_solutions.sql` | Answer key, numbered to match the exercises. |

**Before you start:** run `../Databases/Parch & Posey Database.sql` if you haven't already.

**Order:** `day04_reading.html` → `day04_string_functions_subqueries_ctes.sql` → `day04_exercises.sql`.
