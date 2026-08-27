# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A 9-day self-paced MySQL / SQL-for-Data-Analysis course (see `COURSE_PLAN.md` for the full build plan and source-material provenance, and `README.md` for the day-by-day table of contents). The published content is `.sql` scripts and notebooks (seed data + teaching queries + practice exercises) and a single self-contained `day0N_reading.html` per lesson day (concepts, diagrams, worked examples) — no build/lint/test tooling ships with the course itself, and no separate slide deck: reading material used to be split across a Markdown write-up plus a `.pptx` deck, but that split was replaced with one HTML file per day (see "Reading material format" below) — Days 01–03 have already been rebuilt this way.

Each lesson day (`Day 01`–`Day 05`) follows the same layout, subfolders ordered by a `D0N_0M_` prefix
so they list in read order: `D0N_01_Materials/` (the day's database-setup script plus
`day0N_reading.html`), `D0N_02_Walkthrough/` (the explained, titled SQL or notebook), `D0N_03_Exercises/`
(`day0N_exercises.sql` + `day0N_exercises_solutions.sql`, business-framed, numbered `N.M` to match
the walkthrough's section numbers). Project days (`Day 06`–`Day 09`) instead get a `Reading_0N.md`,
a `project_0N.ipynb`, and a `Data_0N.md` pointing to the (uncommitted) dataset source. Every file
inside a day's subfolders is prefixed `day0N_` so it stays unambiguous outside its folder (e.g. an
editor tab bar showing files from multiple days at once) — this convention started with Day 01 and
applies going forward. `OLD SQL/` and `Updated MySQL Tutorial/` are archived reference material,
excluded from git via `.gitignore` — treat them as read-only source material, not something to edit
or ship.

## Reading material format

Each `D0N_01_Materials/day0N_reading.html` is one self-contained file — no build step, open it
directly in a browser. It replaced an earlier split of a Markdown write-up plus a separately-built
`.pptx` slide deck (that tooling, `_slide_kit/` and each day's `build.py`, is gone — see git history
before this change if it's ever needed again).

- **Design system** (shared across every day's HTML, copy the `<style>` block from the most
  recently built day rather than reinventing it): fonts are Bricolage Grotesque (headings), Nunito
  Sans (body), IBM Plex Mono (code/labels) via Google Fonts `<link>` tags. Color tokens: ink
  `#141414`, blue `#2F63E8` / blue-dark `#1E4BC4`, gray `#5B6472` / gray-muted `#9CA3AF`, panel
  `#F3F4F6`, border `#E5E7EB`, paper background `#FAFBFC`. Code blocks use VS-Code-dark colors:
  background `#1E1E1E`, default text `#D4D4D4` (**must** be set explicitly on `.code-body` — see
  the bug note below), keyword `#569CD6`, function `#DCDCAA`, string `#CE9178`, comment `#6A9955`.
  Component classes: `.objectives` (top-of-page skills box), `.callout` with `.tip`/`.insight`/
  `.warn`/`.recap` variants, `.code-block` + `.code-header` + `.code-body` + `.annotations` (code
  followed by a numbered explanation list), `.compare` with `.good`/`.bad` columns, `.card-grid`
  (2- or 3-column), `figure`/`figcaption`.
- **Diagrams — pick the right tool per diagram, don't default to one:**
  - **Mermaid `erDiagram`** (loaded via CDN, `<script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js">`,
    initialized in a `<script>` before `</body>` with `theme:'base'` and this repo's color tokens
    in `themeVariables`) for any real entity-relationship diagram — table schemas, FK
    relationships. This is the default for ERDs: auto-layout beats hand-placed SVG coordinates for
    correctness and clarity, confirmed directly by the user comparing both. Also usable for
    non-ER diagrams via `flowchart TD`/`LR` (e.g. Day 02's GROUP BY bucketing diagram uses
    `classDef`/`linkStyle` for per-node/per-edge coloring instead of hand-drawn arrows).
  - **Hand-drawn inline SVG** only when Mermaid's diagram grammar can't express the thing being
    taught — e.g. Day 01's Chen-notation diagram (entity=rectangle/attribute=oval/relationship=
    diamond legend) has no Mermaid equivalent. Reuse the shared `<defs>` block (arrow markers
    `#arrow`/`#arrow-blue`, `#soft-shadow` drop-shadow filter) declared once near the top of
    `<body>`. This used to be the default for every diagram; it no longer is — reach for Mermaid
    first.
  - Never embed raster images for diagrams (no image-generation capability) — vector only, either
    Mermaid or hand SVG.
- **Known bug classes to avoid:**
  - `.code-body` needs an explicit base `color` (the default-text token) — without it, any SQL
    token not wrapped in a `.kw`/`.fn`/`.str`/`.com` span inherits the page's near-black body text
    and becomes unreadable against the dark code background.
  - Any literal angle-bracket placeholder used as text inside a code block (e.g. a `<column>`
    placeholder in a skeleton query) must be HTML-escaped as `&lt;column&gt;` — unescaped, it's
    parsed as a real unknown tag and breaks the DOM.
  - Validate a new/edited HTML file with a quick Python `html.parser.HTMLParser` tag-balance check
    before calling it done — override `handle_startendtag` as a no-op and exclude SVG void
    elements (`circle`, `line`, `ellipse`, `polygon`, `rect`, `path`) from the tag stack, or
    self-closing SVG tags register as false-positive mismatches.

## Structure

- `Day 01/` — intro module using the sample **`world`** database (`city`, `country`, `countrylanguage` tables: cities, countries, and languages spoken per country).
  - `D01_01_Materials/` — `world_db.sql` (full `CREATE DATABASE world` + schema + seed data dump —
    run this first to provision the database) and `day01_reading.html`.
  - `D01_02_Walkthrough/day01_sql_foundations.sql` — annotated walkthrough queries, organized into numbered `-- SECTION N — TOPIC` blocks (exploring the server, SELECT, LIMIT/OFFSET, DISTINCT, aggregation/COUNT, ORDER BY) against `world`.
  - `D01_03_Exercises/` — `day01_exercises.sql` (business-framed practice questions numbered `N.M`) and `day01_exercises_solutions.sql` (matching answer key).
- `Day 02/` — the **Parch & Posey** module, a fictional paper-sales company (from Udacity's SQL for Data Analysis course, adapted for MySQL here).
  - `D02_01_Materials/` — `Parch & Posey Database.sql` (MySQL `CREATE DATABASE parch_and_posey` + schema + seed data, ~16k lines, mostly `INSERT` statements — run this first for this module); `Parch_and_Posey.md` + `parch_and_posey_erd.svg` (detailed schema reference — full column list per table, kept as reference material distinct from the lesson itself); `day02_reading.html` (full schema as a Mermaid ERD, `DATE_FORMAT` specifiers as an inline table rather than the old `dates_specifiers.jpg`).
  - `D02_02_Walkthrough/day02_filtering_and_aggregation.sql` — organized into numbered `-- SECTION N — TOPIC` blocks (LIMIT/OFFSET, DISTINCT, ORDER BY, aggregation, WHERE, AND/OR, BETWEEN, IN vs OR, NULL checks, LIKE, GROUP BY, DATE functions). New teaching content should follow this same section-header convention.
  - `D02_03_Exercises/` — `day02_exercises.sql` (practice questions mirroring the walkthrough's sections, numbered `N.M`) and `day02_exercises_solutions.sql` (reference answers keyed to the same numbering).
- `Day 03/` — JOINs + CASE, still on `parch_and_posey` (run Day 02's DB script first — no separate setup script here).
  - `D03_01_Materials/day03_reading.html` (bridges Day 01's 1:1/1:N/N:N relationship types to actual JOIN syntax via a Mermaid N:N diagram, a hand-drawn SVG for the LEFT JOIN unmatched-row case since it's showing specific record instances rather than a schema, plus HAVING vs WHERE and CASE).
  - `D03_02_Walkthrough/day03_joins_and_case.sql` — 10 numbered sections: INNER JOIN basics, multi-table JOINs, JOIN+GROUP BY, JOIN+HAVING, LEFT/RIGHT JOIN, anti-joins, FULL JOIN via UNION, CASE basics, CASE+GROUP BY (tiering), CASE+HAVING.
  - `D03_03_Exercises/` — `day03_exercises.sql` + `day03_exercises_solutions.sql`, same numbering/business-framing convention. Deliberately avoids subqueries/CTEs (that's Day 04) — one sourced question needing a subquery was reworked to use `COUNT(DISTINCT ...)` instead.

## Working with this repo

- To run any script: load it into a MySQL client (MySQL Shell/Workbench, `mysql` CLI, or the VS Code MySQL extension) pointed at a local MySQL server. There's no connection config checked in — connection details are supplied by whatever client opens the file.
- The two schema/seed files (`world_db.sql`, `D02_01_Materials/Parch & Posey Database.sql`) are idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run.
- Exercises reference tables by name only (`region, sales_reps, accounts, orders, web_events` / `city, country, countrylanguage`); the corresponding database script must be run first or the table won't exist.
- When adding a new exercise, keep the day's `D0N_03_Exercises/*_exercises.sql`, `D0N_03_Exercises/*_exercises_solutions.sql`, and `D0N_02_Walkthrough/*` walkthrough file numbered consistently — the solution file's section/question numbers must match the exercise file's.
- Project datasets (Days 06–09) are committed directly when small enough — don't blanket-exclude `*.sqlite`/`*.db`/`*.csv` in `.gitignore`; only skip a specific file that's actually too large for git (e.g. European Soccer's `database.sqlite` at 299 MB, over GitHub's 100 MB hard limit), and link out to it instead.
- Opening a `day0N_reading.html` file needs internet access once, to fetch Google Fonts and the Mermaid CDN script — everything else in the file is self-contained.
