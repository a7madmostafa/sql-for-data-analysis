"""
Executes a lesson-day SQL walkthrough file statement-by-statement against a live
MySQL database and renders SQL + real results as a themed, self-contained HTML
page -- the same "open directly in a browser, no setup" idea as day0N_reading.html,
for lesson days (01-04) that have a .sql walkthrough instead of a notebook.

Usage:
    python _tools/sql_to_html.py "Day 01/day01_sql_foundations.sql" \
        --day 1 --title "SQL Foundations" --database world \
        --out "Day 01/day01_sql_foundations.html"

Requires a local MySQL server with the day's database already loaded
(see Databases/README.md), and .env at the repo root (see .env.example).

Parsing model
-------------
The walkthrough files share one convention throughout: a divider/title/divider
banner ("-- ====", "-- SECTION N -- TITLE", "-- ====") starts each section, and
inside a section, one or more comment lines (the business-question framing)
immediately precede one or more SQL statements. Statements normally end at ';',
but a DELIMITER directive (used around stored procedures) switches the active
terminator until the next DELIMITER. Blank lines separate one comment+statement
group from the next, except inside a still-open multi-line statement (e.g. a
UNION query with a blank line for readability around the UNION keyword), where
a blank line is not a boundary.
"""

import argparse
import html
import os
import re
import sys

import mysql.connector
from dotenv import load_dotenv

SECTION_RE = re.compile(r"^--\s*SECTION\s+(\d+)\s*[—\-]\s*(.+?)\s*$", re.IGNORECASE)
DIVIDER_RE = re.compile(r"^--\s*=+\s*$")
DELIMITER_RE = re.compile(r"^DELIMITER\s+(\S+)\s*$", re.IGNORECASE)
MAX_DISPLAY_ROWS = 15

KEYWORDS = [
    "SELECT", "FROM", "WHERE", "JOIN", "INNER", "LEFT", "RIGHT", "FULL", "OUTER", "ON",
    "GROUP BY", "ORDER BY", "HAVING", "LIMIT", "OFFSET", "AS", "DISTINCT", "CASE", "WHEN",
    "THEN", "ELSE", "END", "WITH", "UNION", "ALL", "IN", "NOT", "NULL", "IS", "AND", "OR",
    "LIKE", "BETWEEN", "CREATE", "VIEW", "PROCEDURE", "DROP", "IF", "EXISTS", "DELIMITER",
    "CALL", "BEGIN", "RETURN", "INTO", "OVER", "PARTITION BY", "DESC", "ASC", "TEMPORARY",
    "TABLE", "INSERT", "UPDATE", "DELETE", "USE", "SHOW", "DESCRIBE", "DATABASES", "SCHEMAS",
    "TABLES", "IN", "OUT", "VALUES", "SET",
]
FUNCTIONS = [
    "COUNT", "SUM", "AVG", "MIN", "MAX", "ROUND", "CONCAT", "COALESCE", "IFNULL",
    "DATE", "DATE_ADD", "DATE_FORMAT", "DATEDIFF", "CURDATE", "NOW", "STRFTIME",
    "RANK", "DENSE_RANK", "ROW_NUMBER", "LAG", "LEAD", "LEFT", "RIGHT", "SUBSTRING",
    "TRIM", "LTRIM", "RTRIM", "REPLACE", "LOCATE", "LENGTH", "UPPER", "LOWER",
]


class SectionHeader:
    def __init__(self, number, title):
        self.number = number
        self.title = title


class StatementGroup:
    def __init__(self, explanation, statements, display_texts=None):
        self.explanation = explanation
        self.statements = statements
        # display_texts holds the exact text to render for each statement --
        # normally just the statement plus its terminator, but a statement
        # preceded by a DELIMITER directive gets that directive prepended and
        # the real terminator (not a hardcoded ";") appended, so DELIMITER
        # blocks around stored procedures render as they were written.
        self.display_texts = display_texts or [s + ";" for s in statements]


def strip_trailing_comment(line):
    idx = line.find("--")
    if idx == -1:
        return line, None
    return line[:idx].rstrip(), line[idx:].strip()


def parse_sql_file(text):
    """Returns a flat list of SectionHeader / StatementGroup objects, in order."""
    lines = text.split("\n")
    events = []

    delimiter = ";"
    comment_buffer = []
    code_buffer = []
    trailing_notes = []
    in_statement = False
    statements = []
    display_texts = []
    # A DELIMITER directive line, waiting to be shown in front of whichever
    # statement comes next. Deliberately NOT reset by flush_group -- a blank
    # line between "DELIMITER $$" and the CREATE PROCEDURE it applies to must
    # not lose it.
    pending_prefix = None
    stmt_prefix = None

    def flush_group():
        nonlocal comment_buffer, code_buffer, statements, trailing_notes, display_texts
        if statements:
            events.append(StatementGroup(" ".join(comment_buffer).strip(), statements, display_texts))
        comment_buffer = []
        code_buffer = []
        statements = []
        display_texts = []
        trailing_notes = []

    for raw_line in lines:
        line = raw_line.rstrip()
        stripped = line.strip()

        if DIVIDER_RE.match(stripped):
            continue

        m = SECTION_RE.match(stripped)
        if m:
            flush_group()
            events.append(SectionHeader(int(m.group(1)), m.group(2)))
            continue

        m = DELIMITER_RE.match(stripped)
        if m and not in_statement:
            flush_group()
            delimiter = m.group(1)
            pending_prefix = stripped
            continue

        if stripped == "":
            if not in_statement:
                flush_group()
            continue

        if stripped.startswith("--"):
            if not in_statement:
                comment_buffer.append(stripped.lstrip("-").strip())
                continue
            # a comment line in the middle of an open statement: keep as-is in the code
            code_buffer.append(line)
            continue

        if not code_buffer and pending_prefix is not None:
            stmt_prefix = pending_prefix
            pending_prefix = None

        code_part, trailing_comment = strip_trailing_comment(line)
        code_buffer.append(code_part if trailing_comment else line)
        if trailing_comment:
            trailing_notes.append(trailing_comment)

        check_text = (code_part if trailing_comment else line).rstrip()
        if check_text.endswith(delimiter):
            stmt_text = "\n".join(code_buffer).strip()
            stmt_text = stmt_text[: -len(delimiter)].rstrip()
            statements.append(stmt_text)
            display_text = stmt_text + delimiter
            if stmt_prefix:
                display_text = stmt_prefix + "\n\n" + display_text
            display_texts.append(display_text)
            stmt_prefix = None
            code_buffer = []
            in_statement = False
        else:
            in_statement = True

    flush_group()
    return events


def highlight_sql(sql_text):
    escaped = html.escape(sql_text)

    def repl_string(m):
        return f'<span class="str">{m.group(0)}</span>'

    escaped = re.sub(r"&#x27;[^&]*?&#x27;", repl_string, escaped)

    def repl_comment(m):
        return f'<span class="com">{m.group(0)}</span>'

    escaped = re.sub(r"--[^\n]*", repl_comment, escaped)

    for kw in sorted(KEYWORDS, key=len, reverse=True):
        pattern = r"(?<![\w])" + re.escape(kw) + r"(?![\w])"
        escaped = re.sub(pattern, lambda m: f'<span class="kw">{m.group(0)}</span>', escaped, flags=re.IGNORECASE)

    for fn in sorted(FUNCTIONS, key=len, reverse=True):
        pattern = r"(?<![\w])(" + re.escape(fn) + r")(?=\s*\()"
        escaped = re.sub(pattern, lambda m: f'<span class="fn">{m.group(0)}</span>', escaped, flags=re.IGNORECASE)

    return escaped


def run_statement(cursor, stmt):
    cursor.execute(stmt)
    if cursor.description is not None:
        cols = [d[0] for d in cursor.description]
        rows = cursor.fetchall()
        result = {"type": "rows", "columns": cols, "rows": rows}
    else:
        rowcount = cursor.rowcount
        result = {"type": "status", "rowcount": rowcount}
    # CALLing a stored procedure leaves a trailing "call status" result even
    # after its own visible result set is fetched -- mysql-connector-python
    # silently misreads the *next* statement's cursor.description as None
    # unless this is drained here. Harmless no-op for a plain statement.
    while cursor.nextset():
        pass
    return result


def render_result_html(result):
    if result["type"] == "rows":
        cols, rows = result["columns"], result["rows"]
        total = len(rows)
        shown = rows[:MAX_DISPLAY_ROWS]
        out = ['<div class="result-wrap">', '<table class="api result-table">', "<thead><tr>"]
        for c in cols:
            out.append(f"<th>{html.escape(str(c))}</th>")
        out.append("</tr></thead><tbody>")
        for row in shown:
            out.append("<tr>")
            for val in row:
                out.append(f"<td>{html.escape('' if val is None else str(val))}</td>")
            out.append("</tr>")
        out.append("</tbody></table>")
        if total > MAX_DISPLAY_ROWS:
            out.append(f'<p class="row-note">showing {MAX_DISPLAY_ROWS} of {total} rows</p>')
        else:
            out.append(f'<p class="row-note">{total} row{"s" if total != 1 else ""}</p>')
        out.append("</div>")
        return "".join(out)
    rc = result["rowcount"]
    if rc is None or rc <= 0:
        note = "executed"
    else:
        note = f"{rc} row{'s' if rc != 1 else ''} affected"
    return f'<div class="result-wrap"><p class="row-note status">&#10003; {note}</p></div>'


DAYS = [
    ("01", "day01_reading.html", "SQL Foundations"),
    ("02", "day02_reading.html", "Filtering &amp; Aggregation"),
    ("03", "day03_reading.html", "JOINs, CASE &amp; Strings"),
    ("04", "day04_reading.html", "Subqueries, CTEs &amp; Views"),
    ("05", "day05_reading.html", "Window Functions &amp; Procedures"),
    ("06", "day06_reading.html", "Python Connectivity"),
    ("07", "day07_reading.html", "Project: Wasel"),
]

SIDEBAR_CSS = """.site-sidebar{position:fixed;top:0;left:0;bottom:0;width:220px;background:var(--panel);border-right:1px solid var(--border);padding:22px 0;overflow-y:auto;z-index:1000}
.site-sidebar .brand{font-family:'Bricolage Grotesque',Georgia,serif;font-weight:800;font-size:14.5px;color:var(--ink);padding:0 20px 16px;border-bottom:1px solid var(--border);margin-bottom:8px;line-height:1.3}
.site-sidebar a{display:block;padding:9px 20px;font-family:'Nunito Sans',-apple-system,'Segoe UI',sans-serif;font-size:14px;color:var(--gray);text-decoration:none;border-left:3px solid transparent}
.site-sidebar a:hover{background:var(--card-bg);color:var(--blue)}
.site-sidebar a.active{background:var(--card-bg);color:var(--blue);font-weight:700;border-left-color:var(--blue)}
.site-sidebar .daynum{font-family:'IBM Plex Mono',monospace;font-size:10.5px;color:var(--gray-muted);display:block;letter-spacing:.08em;text-transform:uppercase;margin-bottom:1px}
.site-sidebar a.active .daynum{color:var(--blue)}
body{margin-left:220px;background:var(--paper)}
.sidebar-toggle{display:none;position:fixed;top:14px;left:14px;z-index:1200;width:40px;height:40px;border-radius:8px;border:1px solid var(--border);background:var(--card-bg);color:var(--ink);font-size:18px;line-height:1;cursor:pointer;box-shadow:0 2px 8px rgba(20,20,30,.08);align-items:center;justify-content:center}
.sidebar-backdrop{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:900}
@media(max-width:900px){
.site-sidebar{width:250px;transform:translateX(-100%);transition:transform .25s ease;box-shadow:2px 0 16px rgba(0,0,0,.18)}
.site-sidebar.open{transform:translateX(0)}
.sidebar-toggle{display:flex}
.sidebar-backdrop.open{display:block}
body{margin-left:0}
}"""

TOGGLE_JS = """<script>
(function(){
  var sidebar = document.querySelector('.site-sidebar');
  var toggle = document.querySelector('.sidebar-toggle');
  var backdrop = document.querySelector('.sidebar-backdrop');
  if(!sidebar || !toggle || !backdrop) return;
  function close(){ sidebar.classList.remove('open'); backdrop.classList.remove('open'); toggle.setAttribute('aria-expanded','false'); }
  function openMenu(){ sidebar.classList.add('open'); backdrop.classList.add('open'); toggle.setAttribute('aria-expanded','true'); }
  toggle.addEventListener('click', function(){
    if (sidebar.classList.contains('open')) close(); else openMenu();
  });
  backdrop.addEventListener('click', close);
})();
</script>"""

ANTI_FLASH_SCRIPT = """<script>
(function(){
  try{
    var saved = localStorage.getItem('theme');
    if(saved === 'dark' || saved === 'light'){
      document.documentElement.setAttribute('data-theme', saved);
    }
  }catch(e){}
})();
</script>"""

DARK_MODE_CSS = """:root[data-theme="dark"]{
  --ink:#E7E9EC; --blue:#4C8DFF; --blue-dark:#9DBBFF; --gray:#A6ADB8; --gray-muted:#767D89;
  --border:#2A2E37; --panel:#191C22; --white:#FFFFFF; --paper:#101216; --card-bg:#1A1D23;
  --insight-bg:#152A1B; --insight-bd:#3D9964; --insight-ti:#6FDB98;
}
@media(prefers-color-scheme:dark){
  :root:not([data-theme="light"]){
    --ink:#E7E9EC; --blue:#4C8DFF; --blue-dark:#9DBBFF; --gray:#A6ADB8; --gray-muted:#767D89;
    --border:#2A2E37; --panel:#191C22; --white:#FFFFFF; --paper:#101216; --card-bg:#1A1D23;
    --insight-bg:#152A1B; --insight-bd:#3D9964; --insight-ti:#6FDB98;
  }
}
body{transition:background-color .15s ease,color .15s ease}
.theme-toggle{position:fixed;top:14px;right:20px;z-index:1200;width:40px;height:40px;border-radius:8px;border:1px solid var(--border);background:var(--card-bg);color:var(--ink);cursor:pointer;box-shadow:0 2px 8px rgba(20,20,30,.08);display:flex;align-items:center;justify-content:center}
.theme-toggle svg{width:18px;height:18px;stroke:currentColor;stroke-width:1.8;fill:none;stroke-linecap:round;stroke-linejoin:round}
.theme-toggle .icon-moon{display:none}
:root[data-theme="dark"] .theme-toggle .icon-sun{display:none}
:root[data-theme="dark"] .theme-toggle .icon-moon{display:block}
@media(prefers-color-scheme:dark){
  :root:not([data-theme="light"]) .theme-toggle .icon-sun{display:none}
  :root:not([data-theme="light"]) .theme-toggle .icon-moon{display:block}
}
:root[data-theme="light"] .theme-toggle .icon-sun{display:block}
:root[data-theme="light"] .theme-toggle .icon-moon{display:none}"""

THEME_TOGGLE_BUTTON = """<button class="theme-toggle" aria-label="Toggle dark mode">
  <svg class="icon-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>
  <svg class="icon-moon" viewBox="0 0 24 24"><path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5z"/></svg>
</button>"""

THEME_TOGGLE_JS = """<script>
(function(){
  var btn = document.querySelector('.theme-toggle');
  if(!btn) return;
  function currentTheme(){
    var attr = document.documentElement.getAttribute('data-theme');
    if(attr === 'dark' || attr === 'light') return attr;
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  btn.addEventListener('click', function(){
    var next = currentTheme() === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    try{ localStorage.setItem('theme', next); }catch(e){}
  });
})();
</script>"""


DAY_LINKS_CSS = """.day-links{display:flex;gap:10px;flex-wrap:wrap;margin:0 0 22px}
.day-links a{font-family:'IBM Plex Mono',monospace;font-size:12.5px;font-weight:700;text-decoration:none;color:var(--blue-dark);background:var(--panel);border:1px solid var(--border);border-radius:6px;padding:6px 11px;display:inline-flex;align-items:center}
.day-links a:hover{background:var(--blue);color:#fff;border-color:var(--blue)}
.day-links a.primary{background:var(--blue);color:#fff;border-color:var(--blue)}
.day-links a.primary:hover{background:var(--blue-dark)}
.dl-icon{width:11px;height:11px;margin-right:5px;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}"""


def render_day_links(day):
    reading_file = f"day{day:02d}_reading.html"
    gh_folder = f"Day%20{day:02d}"
    return (
        '<div class="day-links">\n'
        f'  <a class="primary" href="{reading_file}">Reading</a>\n'
        f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/{gh_folder}" target="_blank" rel="noopener"><svg class="dl-icon"><use href="#icon-external"/></svg>Walkthrough &amp; Exercises</a>\n'
        "</div>"
    )


def render_sidebar(active_day):
    parts = [
        '<button class="sidebar-toggle" aria-label="Toggle navigation" aria-expanded="false">&#9776;</button>',
        THEME_TOGGLE_BUTTON,
        '<div class="sidebar-backdrop"></div>',
        '<nav class="site-sidebar">',
        '<div class="brand">SQL for Data Analysis</div>',
        '<a href="../index.html">Home</a>',
    ]
    for num, fname, title in DAYS:
        cls = ' class="active"' if num == active_day else ""
        parts.append(f'<a href="../Day%20{num}/{fname}"{cls}><span class="daynum">Day {num}</span>{title}</a>')
    parts.append("</nav>")
    return "\n".join(parts)


PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Day {day:02d} Walkthrough &mdash; {title}</title>
{anti_flash_script}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;700;800&family=Nunito+Sans:wght@400;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root{{
  --ink:#141414; --blue:#2F63E8; --blue-dark:#1E4BC4; --gray:#5B6472; --gray-muted:#9CA3AF;
  --border:#E5E7EB; --panel:#F3F4F6; --white:#FFFFFF; --paper:#FAFBFC; --card-bg:#FFFFFF;
  --code-bg:#1E1E1E; --code-default:#D4D4D4; --code-kw:#569CD6; --code-fn:#DCDCAA;
  --code-str:#CE9178; --code-com:#6A9955;
  --insight-bg:#E8F5E9; --insight-bd:#1E8449; --insight-ti:#1E5631;
}}
{dark_css}
*{{box-sizing:border-box}} html,body{{margin:0;padding:0}}
body{{background:var(--paper);color:var(--ink);font-family:'Nunito Sans',-apple-system,'Segoe UI',sans-serif;line-height:1.7;font-size:16px}}
.page{{max-width:920px;margin:0 auto;padding:56px 48px 90px}}
.crumb{{font-family:'IBM Plex Mono',monospace;font-size:12px;letter-spacing:.14em;text-transform:uppercase;color:var(--blue);font-weight:700;margin-bottom:14px}}
{sidebar_css}
h1.title{{font-family:'Bricolage Grotesque',Georgia,serif;font-size:38px;line-height:1.15;color:var(--ink);margin:0 0 12px;font-weight:800}}
.subtitle{{font-size:17px;color:var(--gray);margin:0 0 30px}}
h2.section{{font-family:'Bricolage Grotesque',Georgia,serif;font-size:24px;color:var(--ink);margin:48px 0 8px;padding-bottom:9px;border-bottom:2px solid var(--ink);font-weight:700}}
h2.section .num{{color:var(--blue);margin-right:10px}}
p{{margin:0 0 12px}}
p.explain{{font-size:15.5px;color:var(--gray);margin:22px 0 8px}}
strong{{color:var(--ink);font-weight:700}}
code.inline{{font-family:'IBM Plex Mono',monospace;font-size:.88em;background:var(--panel);border:1px solid var(--border);border-radius:3px;padding:1px 6px;color:var(--blue-dark)}}

.code-block{{margin:8px 0 0;border-radius:8px 8px 0 0;overflow:hidden;box-shadow:0 4px 14px rgba(20,20,30,.12)}}
.code-header{{display:flex;align-items:center;gap:10px;padding:8px 14px;background:#161616}}
.code-header .dot{{width:10px;height:10px;border-radius:50%}}
.code-header .dot.r{{background:#FF5F56}}.code-header .dot.y{{background:#FFBD2E}}.code-header .dot.g{{background:#27C93F}}
.code-header .fname{{font-family:'IBM Plex Mono',monospace;font-size:12px;color:#9C9C9C;margin-left:6px}}
.code-body{{background:var(--code-bg);color:var(--code-default);padding:14px 20px;font-family:'IBM Plex Mono',monospace;font-size:13.5px;line-height:1.7;overflow-x:auto;white-space:pre}}
.code-body .kw{{color:var(--code-kw)}}.code-body .fn{{color:var(--code-fn)}}
.code-body .str{{color:var(--code-str)}}.code-body .com{{color:var(--code-com);font-style:italic}}

.result-wrap{{background:var(--card-bg);border:1px solid var(--border);border-top:none;border-radius:0 0 8px 8px;padding:14px 18px 10px;margin-bottom:26px;overflow-x:auto}}
table.result-table{{width:auto;min-width:100%;border-collapse:collapse;margin:0;background:var(--card-bg);font-size:13.5px;border-radius:6px;overflow:hidden;border:1px solid var(--border)}}
table.result-table th,table.result-table td{{padding:8px 12px;border-bottom:1px solid var(--border);text-align:left;vertical-align:top;white-space:nowrap}}
table.result-table thead th{{background:var(--panel);color:var(--ink);font-size:11px;text-transform:uppercase;letter-spacing:.06em}}
table.result-table tbody tr:last-child td{{border-bottom:none}}
.row-note{{font-family:'IBM Plex Mono',monospace;font-size:12px;color:var(--gray-muted);margin:8px 0 0}}
.row-note.status{{color:var(--insight-ti)}}

.callout{{margin:22px 0 26px;border-radius:6px;padding:15px 20px 17px;border-left:4px solid var(--blue);background:var(--panel)}}
.callout .ti{{font-family:'IBM Plex Mono',monospace;font-size:11.5px;text-transform:uppercase;letter-spacing:.1em;font-weight:700;margin-bottom:7px;color:var(--blue-dark)}}
.callout p{{font-size:14.5px;margin:0}}

footer{{margin-top:56px;padding-top:20px;border-top:1px solid var(--border);color:var(--gray-muted);font-size:12px;text-align:center;font-family:'IBM Plex Mono',monospace}}
@media(max-width:760px){{.page{{padding:32px 22px}}h1.title{{font-size:28px}}}}
{day_links_css}
</style>
</head>
<body>
{sidebar}
<div class="page">

<svg width="0" height="0" style="position:absolute">
  <defs>
    <symbol id="icon-download" viewBox="0 0 16 16">
      <path d="M8 2v7M4.5 6.5L8 10l3.5-3.5M2.5 12.5h11"/>
    </symbol>
    <symbol id="icon-external" viewBox="0 0 16 16">
      <path d="M6.5 2.5h7v7M13.5 2.5L6 10M4 4H2.5v9.5H12V12"/>
    </symbol>
  </defs>
</svg>

<div class="crumb">Day {day:02d} of 7 &middot; Walkthrough</div>
<h1 class="title">{title}</h1>
<p class="subtitle">Every statement from <code class="inline">{sql_filename}</code>, executed live against <code class="inline">{database}</code> &mdash; SQL and real output, side by side.</p>

{day_links}

<div class="callout">
  <div class="ti">Generated page</div>
  <p>This page is generated from <code class="inline">{sql_filename}</code> by running it statement-by-statement
  against a local MySQL server and capturing the real output &mdash; it is not hand-written. If the walkthrough
  file changes, regenerate this page rather than editing it directly.</p>
</div>

{body}

<footer>Day {day:02d} &middot; {title} &middot; walkthrough &middot; self-paced</footer>
</div>
{toggle_js}
{theme_toggle_js}
</body></html>
"""


def render_page(day, title, database, sql_filename, events):
    body_parts = []
    for ev in events:
        if isinstance(ev, SectionHeader):
            body_parts.append(f'<h2 class="section"><span class="num">{ev.number}</span>{html.escape(ev.title)}</h2>')
        else:
            explain_html = html.escape(ev.explanation)
            explain_html = re.sub(r"`([^`]+)`", r"<code>\1</code>", explain_html)
            body_parts.append(f'<p class="explain">{explain_html}</p>')
            code_text = "\n\n".join(ev.display_texts)
            body_parts.append(
                '<div class="code-block"><div class="code-header">'
                '<span class="dot r"></span><span class="dot y"></span><span class="dot g"></span>'
                f'<span class="fname">{html.escape(sql_filename)}</span></div>'
                f'<div class="code-body">{highlight_sql(code_text)}</div></div>'
            )
            for result in ev.rendered_results:
                body_parts.append(render_result_html(result))
    return PAGE_TEMPLATE.format(
        day=day, title=html.escape(title), database=html.escape(database),
        sql_filename=html.escape(sql_filename), body="\n".join(body_parts),
        sidebar_css=SIDEBAR_CSS, sidebar=render_sidebar(f"{day:02d}"),
        toggle_js=TOGGLE_JS, day_links_css=DAY_LINKS_CSS, day_links=render_day_links(day),
        anti_flash_script=ANTI_FLASH_SCRIPT, dark_css=DARK_MODE_CSS, theme_toggle_js=THEME_TOGGLE_JS,
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sql_file")
    parser.add_argument("--day", type=int, required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--database", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    load_dotenv()
    text = open(args.sql_file, encoding="utf-8").read()
    events = parse_sql_file(text)

    conn = mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD"),
        database=args.database,
        use_pure=True,
    )
    cursor = conn.cursor()

    for ev in events:
        if isinstance(ev, StatementGroup):
            ev.rendered_results = []
            for stmt in ev.statements:
                try:
                    result = run_statement(cursor, stmt)
                except mysql.connector.Error as e:
                    result = {"type": "status", "rowcount": None}
                    print(f"WARNING: statement failed: {stmt[:80]!r} -> {e}", file=sys.stderr)
                ev.rendered_results.append(result)

    cursor.close()
    conn.close()

    html_out = render_page(args.day, args.title, args.database, os.path.basename(args.sql_file), events)
    with open(args.out, "w", encoding="utf-8") as f:
        f.write(html_out)
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
