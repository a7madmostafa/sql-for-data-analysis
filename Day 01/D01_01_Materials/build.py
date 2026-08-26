"""Builds 'Day 01 - SQL Foundations.pptx' from deckkit. Run with:
    python build.py
(needs the repo-root _slide_kit/ on sys.path — handled below)

Content merges two sources:
  - Concepts (slides 3-11): condensed from "SQL for Data Analysis.pdf"
    (what SQL/a database/DBMS is, relational vs NoSQL, entities/attributes/
    relationships, the three relationship types, CRUD, DML/DDL/DCL/TCL,
    why SQL matters for analysis, MySQL basics)
  - Hands-on (slides 13-18): the original sql_basics.sql walkthrough, now day01_sql_foundations.sql
"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "_slide_kit"))
from deckkit import Deck, MARGIN, GRAY
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches

deck = Deck()

# ---------------------------------------------------------------- Slide 1 --
deck.title_slide(
    "SQL Foundations · Day 1 of 9",
    "SQL Foundations",
    "What SQL is, why it matters, and your first queries",
    "Concepts + world database · self-paced",
)

# ---------------------------------------------------------------- Slide 2 --
deck.agenda_slide(
    "Day 01 · Agenda", "What we cover today", "From \"what is a database\" to your first SELECT",
    [
        ("01", "What is SQL?", "A language for talking to databases"),
        ("02", "What is a Database?", "Storage, retrieval, manipulation, security"),
        ("03", "Types of Databases", "Relational (SQL) vs. non-relational (NoSQL)"),
        ("04", "Database Design", "Entities, attributes, and relationships"),
        ("05", "CRUD & SQL Statement Types", "Create/Read/Update/Delete, DML/DDL/DCL/TCL"),
        ("06", "SQL for Data Analysis", "Why this skill matters, with a real example"),
        ("07", "MySQL", "What it is, who uses it, installing it"),
        ("08", "Hands-On", "SELECT, LIMIT/OFFSET, DISTINCT, COUNT, ORDER BY"),
    ],
)

# ---------------------------------------------------------------- Slide 3 --
deck.cards_slide(
    "Concepts · What is SQL", "What is SQL?", "Structured Query Language",
    [
        ("The language of databases", "Just like English or French lets you talk to a person, SQL lets you talk to a database — ask it questions, and tell it what to change."),
        ("A tool for relational data", "Purpose-built for managing and manipulating data stored in relational databases — tables with rows and columns."),
        ("Decades old, still standard", "First developed by IBM in the 1970s. Still the industry-standard way to work with relational data today."),
    ],
)

# ---------------------------------------------------------------- Slide 4 --
deck.grid_slide(
    "Concepts · What is a Database", "What is a database?",
    "A structured collection of data, organized for efficient retrieval — managed by a DBMS (Database Management System), the software that sits between the database and you.",
    [
        ("Data Storage", "Stores data persistently on disk or in memory — durable and available even after a system failure."),
        ("Data Retrieval", "Lets you pull data back out efficiently: filtering, sorting, and aggregating to get exactly what you need."),
        ("Data Manipulation", "Lets you modify data as needed — insert new records, update existing ones, delete what's unwanted."),
        ("Data Security", "Enforces access control — authentication, authorization, and encryption to keep data safe and private."),
    ],
    columns=2,
)

# ---------------------------------------------------------------- Slide 5 --
deck.database_types_slide(
    "Concepts · Types of Databases", "Relational vs. non-relational", None,
    relational={
        "heading": "Relational (RDBMS)",
        "desc": "Organizes data into tables of rows and columns, with relationships between them. Queried with SQL — what this course uses.",
        "examples": "MySQL, PostgreSQL, SQL Server",
    },
    nosql={
        "heading": "Non-relational (NoSQL)",
        "desc": "Stores data as key-value pairs, documents, or graphs — built for large volumes of unstructured or semi-structured data.",
        "examples": "MongoDB, Cassandra, Redis",
    },
)

# ---------------------------------------------------------------- Slide 6 --
deck.entity_attribute_slide(
    "Concepts · Database Design", "Entities, attributes, relationships",
    "An order belongs to a customer, and a customer can place many orders",
    left_entity="Customer", right_entity="Order", relationship="places",
    left_attrs=["name", "email"],
    right_attrs=["date", "total"],
)

# ---------------------------------------------------------------- Slide 7 --
deck.relationship_diagram_slide(
    "Concepts · Relationships", "Three types of relationships",
    "Established by a primary key (uniquely identifies a row) and a foreign key (references another table's primary key)",
    [
        {"kind": "1:1", "left_label": "Country", "right_label": "Capital",
         "caption": "Every country has exactly one capital city."},
        {"kind": "1:N", "left_label": "Mother", "right_label": "Kid",
         "caption": "A mother can have many kids, but every child belongs to exactly one mother."},
        {"kind": "N:N", "left_label": "Book", "right_label": "Author",
         "caption": "A book can have multiple authors, and an author can write multiple books."},
    ],
)

# ---------------------------------------------------------------- Slide 8 --
deck.grid_slide(
    "Concepts · CRUD", "CRUD — the foundation of working with data", "The four operations underlying any database-backed system",
    [
        ("Create", "Create a database or table; insert a new record or column."),
        ("Read", "Select existing record(s) — the operation this whole lesson focuses on."),
        ("Update", "Modify an existing table's data."),
        ("Delete", "Remove a record, column, table, or database."),
    ],
    columns=2,
    accent_numbers=True,
)

# ---------------------------------------------------------------- Slide 9 --
deck.grid_slide(
    "Concepts · SQL Statement Types", "The four categories of SQL statements", "Every SQL statement you'll ever write falls into one of these",
    [
        ("DML — Data Manipulation", "Day-to-day work with data: SELECT, INSERT, UPDATE, DELETE. This course lives almost entirely here."),
        ("DDL — Data Definition", "Defines structure: CREATE, ALTER, DROP — building and changing tables and databases."),
        ("DCL — Data Control", "Controls access: GRANT, REVOKE — who's allowed to do what."),
        ("TCL — Transaction Control", "Controls transactions: COMMIT, ROLLBACK — making a set of changes permanent or undoing them."),
    ],
    columns=2,
)

# --------------------------------------------------------------- Slide 10 --
deck.code_slide(
    "Concepts · Why SQL", "SQL for data analysis", "You manage a bookstore. Which books sold the most this month?",
    "motivating_example.sql",
    [
        "SELECT",
        "    title,",
        "    SUM(quantity_sold) AS total_sold",
        "FROM sales",
        "GROUP BY title",
        "ORDER BY total_sold DESC;",
        "",
        "-- Don't worry about every keyword yet —",
        "-- GROUP BY is Day 02. The point: a few lines",
        "-- of SQL beat sifting through data by hand.",
    ],
    notes=[
        ("No manual digging", "One query answers it instead of scrolling through every sale by hand."),
        ("Scales to real questions", "Top-sellers, revenue trends, average order value, new customers — same idea every time."),
        ("A core analyst skill", "This is how you turn raw data into decisions."),
    ],
)

# --------------------------------------------------------------- Slide 11 --
deck.cards_slide(
    "Concepts · MySQL", "MySQL", "The relational database this whole course runs on",
    [
        ("Free & open-source", "A widely-used relational database management system (RDBMS) — no license cost to get started."),
        ("Scales from small to large", "Fine for a student project, and powers huge production systems too."),
        ("Who uses it", "Facebook, Twitter, Airbnb, Booking.com, Uber, GitHub, YouTube, and CMS platforms like WordPress and Drupal."),
    ],
    panel_title="Installing MySQL",
    panel_lines=[
        "Windows installer: dev.mysql.com/downloads/installer",
        "Workbench setup guide: simplilearn.com — search \"MySQL Workbench installation\"",
        "Once installed, run world_db.sql to load this lesson's database.",
    ],
)

# --------------------------------------------------------------- Slide 12 --
_s12 = deck.erd_slide(
    "Hands-On · The Dataset", "The world database",
    "Everything from here on queries this database — run world_db.sql first, then USE world;",
    center=("country", "Code · Name · Continent\nRegion · Population · GNP"),
    branches=[
        ("city", "ID · Name · CountryCode\nDistrict · Population", "N"),
        ("countrylanguage", "CountryCode · Language\nIsOfficial · Percentage", "N"),
    ],
)
deck._caption(
    _s12, MARGIN, Inches(6.6), Inches(11.5),
    "This lesson stays inside country — city and countrylanguage come in once JOINs are introduced on Day 03.",
    size=13, color=GRAY, align=PP_ALIGN.LEFT,
)

# --------------------------------------------------------------- Slide 13 --
deck.code_slide(
    "Hands-On · SELECT", "Anatomy of a SELECT", "Every query in this lesson follows the same skeleton",
    "day01_sql_foundations.sql",
    [
        "SELECT Region, Continent, Name",
        "FROM country;",
        "",
        "-- SELECT * means \"give me every column\"",
        "SELECT *",
        "FROM country;",
    ],
    notes=[
        ("Name columns explicitly", "Clearer what the query returns, and it won't silently break if a column is added later."),
        ("SELECT *", "Fine for a quick look, risky to leave in real work."),
    ],
)

# --------------------------------------------------------------- Slide 14 --
deck.limit_offset_diagram_slide(
    "Hands-On · LIMIT & OFFSET", "Skip, then take",
    "LIMIT 3 OFFSET 2 on an 8-row table — skip the first 2 rows, return the next 3",
    total_rows=8, offset=2, limit=3,
)

# --------------------------------------------------------------- Slide 15 --
deck.code_slide(
    "Hands-On · LIMIT & OFFSET", "Capping and paging results", "Two ways to write the same thing in MySQL",
    "day01_sql_foundations.sql",
    [
        "-- standard SQL",
        "SELECT * FROM country",
        "LIMIT 3 OFFSET 2;",
        "",
        "-- MySQL shortcut: LIMIT skip, count",
        "SELECT * FROM country",
        "LIMIT 2,3;",
    ],
    notes=[
        ("Same result", "Both return 3 rows, after skipping the first 2."),
        ("Prefer OFFSET", "The shortcut form is easy to misread — is the first number the skip or the count?"),
        ("Real use", "This is exactly how \"page 2 of results\" works in an application."),
    ],
)

# --------------------------------------------------------------- Slide 16 --
deck.code_slide(
    "Hands-On · DISTINCT", "Unique values only", "Answers \"what are the possible values?\", not \"what's the value per row?\"",
    "day01_sql_foundations.sql",
    [
        "SELECT DISTINCT Region",
        "FROM country;",
        "",
        "-- No DISTINCT: one row PER COUNTRY",
        "-- 'Asia' repeated for every Asian country",
    ],
    notes=[
        ("Collapses duplicates", "Down to one row per unique value."),
        ("Combine with COUNT", "COUNT(DISTINCT Region) counts how many unique values exist — next section."),
    ],
)

# --------------------------------------------------------------- Slide 17 --
deck.code_slide(
    "Hands-On · Aggregation", "COUNT — your first aggregate function", "Many rows in, one number out",
    "day01_sql_foundations.sql",
    [
        "SELECT COUNT(*) AS CNTRY_CNT",
        "FROM country;",
        "",
        "SELECT COUNT(Code) no_of_countries",
        "FROM country;",
        "",
        "SELECT COUNT(DISTINCT Region) AS Regions_CNT",
        "FROM country;",
    ],
    notes=[
        ("COUNT(*)", "Counts every row, full stop."),
        ("COUNT(col)", "Counts only non-NULL values — matters once a column can be missing."),
        ("AS is optional", "COUNT(*) CNTRY_CNT works too — writing AS is just clearer."),
    ],
)

# --------------------------------------------------------------- Slide 18 --
deck.code_slide(
    "Hands-On · ORDER BY", "Sorting — and \"top N\" queries", "ASC is the default direction, so it's rarely written",
    "day01_sql_foundations.sql",
    [
        "SELECT Name, Population",
        "FROM country",
        "ORDER BY Name ASC",
        "LIMIT 5;",
        "",
        "-- Top 5 by population",
        "SELECT Name, Population",
        "FROM country",
        "ORDER BY Population DESC",
        "LIMIT 5;",
    ],
    notes=[
        ("Sort by any column", "Even one that isn't in your SELECT list."),
        ("ORDER BY + LIMIT", "Together, this is how you answer \"top N\" questions."),
    ],
)

# --------------------------------------------------------------- Slide 19 --
deck.closing_slide(
    "Next: Day 02", "Filtering & Aggregation",
    "WHERE conditions, GROUP BY, and DATE functions — on a new dataset, parch_and_posey.",
)

out = deck.save(os.path.join(os.path.dirname(__file__), "Day 01 - SQL Foundations.pptx"))
print("Saved:", out)
