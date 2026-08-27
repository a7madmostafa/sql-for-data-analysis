# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A 9-day self-paced MySQL / SQL-for-Data-Analysis course (see `COURSE_PLAN.md` for the full build plan and source-material provenance, and `README.md` for the day-by-day table of contents). The published content is `.sql` scripts and notebooks (seed data + teaching queries + practice exercises) and a single self-contained `day0N_reading.html` per lesson day (concepts, diagrams, worked examples) — no build/lint/test tooling ships with the course itself, and no separate slide deck: reading material used to be split across a Markdown write-up plus a `.pptx` deck, but that split was replaced with one HTML file per day (see "Reading material format" below) — Days 01–03 have already been rebuilt this way.

`Databases/` at the repo root holds every shared database-provisioning script (`world_db.sql`,
`Parch & Posey Database.sql`, and any future one) — not inside a lesson day's own folder, since
`Parch & Posey Database.sql` alone is shared by Days 02–05. Any new database a later day introduces
goes here too.

Each lesson day (`Day 01`–`Day 05`) is one **flat folder, no subfolders** — `day0N_reading.html`,
the walkthrough SQL/notebook, `day0N_exercises.sql` + `day0N_exercises_solutions.sql`
(business-framed, numbered `N.M` to match the walkthrough's section numbers), and a `README.md`
indexing that day's files, a "what you'll learn" summary, and the order to work through them. Days
01–03 originally used numbered subfolders (`D0N_01_Materials/`, `D0N_02_Walkthrough/`,
`D0N_03_Exercises/`) to force read-order in a plain file browser — dropped once every file already
carried a unique `day0N_` prefix, since the subfolder numbering was solving a problem the filename
prefix already solved; the per-day `README.md` is what now provides the "what order do I open these
in" guidance the subfolders used to. Every file is still prefixed `day0N_` so it stays unambiguous
outside its folder (e.g. an editor tab bar showing files from multiple days at once) — that part of
the convention is unchanged. Project days (`Day 06`–`Day 09`) instead get a `Reading_0N.md`, a
`project_0N.ipynb`, and a `Data_0N.md` pointing to the (uncommitted) dataset source — flat already,
no subfolders to remove. `OLD SQL/` and `Updated MySQL Tutorial/` are archived reference material,
excluded from git via `.gitignore` — treat them as read-only source material, not something to edit
or ship.

## Reading material format

Each `day0N_reading.html` is one self-contained file — no build step, open it directly in a
browser. It replaced an earlier split of a Markdown write-up plus a separately-built `.pptx` slide
deck (that tooling, `_slide_kit/` and each day's `build.py`, is gone — see git history before this
change if it's ever needed again).

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
- **Diagrams — every diagram is hand-drawn inline SVG in one consistent "blueprint" style,
  no Mermaid.** This course briefly used Mermaid (`erDiagram`/`flowchart` via CDN) for ERDs, on the
  reasoning that auto-layout beats hand-placed coordinates — but the user later pointed to a
  pre-existing hand-drawn ERD asset (`Day 02/day02_reading.html`'s dataset diagram, originally
  `parch_and_posey_erd.svg`) and said its crow's-foot style should be used for every diagram in the
  course; Mermaid was removed entirely (CDN `<script>`, `.mermaid` CSS, and the `mermaid.initialize`
  block) from all three days' HTML files. Do not reintroduce Mermaid — match this style instead:
  - **White background + subtle grid**: `<pattern id="erd-grid">` (18×18 cell, `#e6edf3` 1px
    lines) declared once in the shared `<defs>` block near the top of `<body>`, referenced via
    `<rect fill="url(#erd-grid)"/>` behind every diagram.
  - **Table/entity cards**: square corners (no `rx`), white fill, `#333` stroke at `1.4`
    stroke-width. Header bar same width, height `30`, fill `#dfe3e8`, `#333` stroke; title
    centered, `fill="#1f6fb2"`, bold, `font-size 15`. A vertical divider line at `x+34` separates a
    label gutter (`PK`/`FK`, bold, size `12`, centered in the gutter) from column names (size `13`,
    left-aligned at roughly `x+46`). Row height `26`; horizontal divider lines between rows (not
    after the last one). This is the exact structure of `Day 02/day02_reading.html`'s schema
    diagram — copy its markup as the template for a new table card.
  - **Relationships**: `#333` `1.4`-width polylines/lines between cards, with real crow's-foot
    notation drawn as small paths, not colored circles — a "one" end is a short perpendicular tick
    (`<path d="M x,y-6 L x,y+6"/>`), a "many" end is a three-point chevron opening away from the
    entity (`<path d="M x,y-12 L x-12,y L x,y+12"/>`, mirrored for the opposite direction).
  - **Font**: `Segoe UI, Arial, sans-serif` set once on the root `<svg font-family="...">` — text
    elements inherit it, no per-element `font-family` needed. This differs from the page's own
    Bricolage/Nunito/IBM-Plex-Mono system deliberately; diagrams are a distinct visual language from
    prose.
  - **No drop shadows, no rounded corners, no soft pastel fills** — flat and crisp. A relationship
    diagram that isn't a schema (e.g. Day 01's LIMIT/OFFSET row-strip, Day 02's BETWEEN number-line,
    Day 03's LEFT JOIN unmatched-row example) still uses the white+grid background, `#333`/`#1f6fb2`
    palette, and Segoe UI, even though it isn't drawing PK/FK table cards.
  - The one intentional exception to crow's-foot notation specifically (not to the visual palette)
    is Day 01's Chen-notation diagram (rectangle=entity, oval=attribute, diamond=relationship) —
    it's teaching a different, named notation, so it keeps its own shapes, restyled to the same
    palette/font/grid-background rather than redrawn as crow's-foot.
  - Never embed raster images for diagrams (no image-generation capability) — vector only.
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

- `Databases/` — `world_db.sql` (full `CREATE DATABASE world` + schema + seed data dump) and `Parch & Posey Database.sql` (MySQL `CREATE DATABASE parch_and_posey` + schema + seed data, ~16k lines, mostly `INSERT` statements) — see `Databases/README.md`.
- `Day 01/` — intro module using the sample **`world`** database (`city`, `country`, `countrylanguage` tables: cities, countries, and languages spoken per country). `day01_reading.html`, `day01_sql_foundations.sql` (annotated walkthrough, numbered `-- SECTION N — TOPIC` blocks: exploring the server, SELECT, LIMIT/OFFSET, DISTINCT, aggregation/COUNT, ORDER BY), `day01_exercises.sql` + `day01_exercises_solutions.sql` (business-framed, numbered `N.M`), `README.md` (this day's index).
- `Day 02/` — the **Parch & Posey** module, a fictional paper-sales company (from Udacity's SQL for Data Analysis course, adapted for MySQL here). `day02_reading.html` (full schema as a hand-drawn crow's-foot ERD SVG — copied directly from the same markup used to build the schema diagram, `DATE_FORMAT` specifiers as an inline table rather than a `.jpg`); `day02_filtering_and_aggregation.sql` (walkthrough, numbered `-- SECTION N — TOPIC` blocks: LIMIT/OFFSET, DISTINCT, ORDER BY, aggregation, WHERE, AND/OR, BETWEEN, IN vs OR, NULL checks, LIKE, GROUP BY, DATE functions — new teaching content should follow this same convention); `day02_exercises.sql` + `day02_exercises_solutions.sql`; `README.md`. (`Parch_and_Posey.md` + `parch_and_posey_erd.svg`, a separate schema-reference doc, were dropped as redundant once the schema lived directly in `day02_reading.html`.)
- `Day 03/` — JOINs + CASE, still on `parch_and_posey` (run `Databases/Parch & Posey Database.sql` first — no separate setup script here). `day03_reading.html` (bridges Day 01's 1:1/1:N/N:N relationship types to actual JOIN syntax, plus HAVING vs WHERE and CASE); `day03_joins_and_case.sql` (walkthrough, 10 numbered sections: INNER JOIN basics, multi-table JOINs, JOIN+GROUP BY, JOIN+HAVING, LEFT/RIGHT JOIN, anti-joins, FULL JOIN via UNION, CASE basics, CASE+GROUP BY (tiering), CASE+HAVING); `day03_exercises.sql` + `day03_exercises_solutions.sql` (same numbering/business-framing convention, deliberately avoids subqueries/CTEs — that's Day 04; one sourced question needing a subquery was reworked to use `COUNT(DISTINCT ...)` instead); `README.md`.

## Working with this repo

- To run any script: load it into a MySQL client (MySQL Shell/Workbench, `mysql` CLI, or the VS Code MySQL extension) pointed at a local MySQL server. There's no connection config checked in — connection details are supplied by whatever client opens the file.
- The two schema/seed files (`Databases/world_db.sql`, `Databases/Parch & Posey Database.sql`) are idempotent-ish (`CREATE TABLE IF NOT EXISTS`, `INSERT IGNORE`) — safe to re-run.
- Exercises reference tables by name only (`region, sales_reps, accounts, orders, web_events` / `city, country, countrylanguage`); the corresponding database script must be run first or the table won't exist.
- Every lesson day is a flat folder (no subfolders) with a `README.md` indexing its files — add one when a new day is built. When adding a new exercise, keep that day's `day0N_exercises.sql`, `day0N_exercises_solutions.sql`, and walkthrough file numbered consistently — the solution file's section/question numbers must match the exercise file's.
- Project datasets (Days 06–09) are committed directly when small enough — don't blanket-exclude `*.sqlite`/`*.db`/`*.csv` in `.gitignore`; only skip a specific file that's actually too large for git (e.g. European Soccer's `database.sqlite` at 299 MB, over GitHub's 100 MB hard limit), and link out to it instead.
- Opening a `day0N_reading.html` file needs internet access once, to fetch Google Fonts — everything else in the file, including every diagram, is self-contained inline SVG.
