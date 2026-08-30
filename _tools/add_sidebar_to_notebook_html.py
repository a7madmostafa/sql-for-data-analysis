"""
Injects the course-wide sidebar nav (and its mobile hamburger toggle) into a
Day 06 notebook's nbconvert HTML export.

nbconvert has no notion of this course's site chrome, so the sidebar can't live in
the notebook source -- it's added as a post-processing pass after every
`jupyter nbconvert --to html` run. Re-run this whenever a Day 06 notebook is
reconverted (day06_python_mysql.html, day06_python_sqlite.html,
day06_exercises.html, day06_exercises_solutions.html all need it).

Usage:
    python _tools/add_sidebar_to_notebook_html.py "Day 06/day06_python_mysql.html" [...]
"""

import re
import sys

DAYS = [
    ("01", "day01_reading.html", "SQL Foundations"),
    ("02", "day02_reading.html", "Filtering &amp; Aggregation"),
    ("03", "day03_reading.html", "JOINs, CASE &amp; Strings"),
    ("04", "day04_reading.html", "Subqueries, CTEs &amp; Views"),
    ("05", "day05_reading.html", "Window Functions &amp; Procedures"),
    ("06", "day06_reading.html", "Python Connectivity"),
    ("07", "day07_reading.html", "Project: Wasel"),
]

SIDEBAR_CSS = """<style>
.site-sidebar{position:fixed;top:0;left:0;bottom:0;width:220px;background:#F3F4F6;border-right:1px solid #E5E7EB;padding:22px 0;overflow-y:auto;z-index:1000}
.site-sidebar .brand{font-family:Georgia,serif;font-weight:800;font-size:14.5px;color:#141414;padding:0 20px 16px;border-bottom:1px solid #E5E7EB;margin-bottom:8px;line-height:1.3}
.site-sidebar a{display:block;padding:9px 20px;font-family:-apple-system,'Segoe UI',sans-serif;font-size:14px;color:#5B6472;text-decoration:none;border-left:3px solid transparent}
.site-sidebar a:hover{background:#fff;color:#2F63E8}
.site-sidebar a.active{background:#fff;color:#2F63E8;font-weight:700;border-left-color:#2F63E8}
.site-sidebar .daynum{font-family:monospace;font-size:10.5px;color:#9CA3AF;display:block;letter-spacing:.08em;text-transform:uppercase;margin-bottom:1px}
.site-sidebar a.active .daynum{color:#2F63E8}
body{margin-left:220px}
.sidebar-toggle{display:none;position:fixed;top:14px;left:14px;z-index:1200;width:40px;height:40px;border-radius:8px;border:1px solid #E5E7EB;background:#fff;font-size:18px;line-height:1;cursor:pointer;box-shadow:0 2px 8px rgba(20,20,30,.08);align-items:center;justify-content:center}
.sidebar-backdrop{display:none;position:fixed;inset:0;background:rgba(20,20,20,.35);z-index:900}
@media(max-width:900px){
.site-sidebar{width:250px;transform:translateX(-100%);transition:transform .25s ease;box-shadow:2px 0 16px rgba(0,0,0,.18)}
.site-sidebar.open{transform:translateX(0)}
.sidebar-toggle{display:flex}
.sidebar-backdrop.open{display:block}
body{margin-left:0}
}
</style>
"""

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
</script>
"""

DAY_LINKS_CSS = """<style>
.day-links{display:flex;gap:10px;flex-wrap:wrap;margin:16px 0 22px}
.day-links a{font-family:monospace;font-size:12.5px;font-weight:700;text-decoration:none;color:#1E4BC4;background:#F3F4F6;border:1px solid #E5E7EB;border-radius:6px;padding:6px 11px;display:inline-flex;align-items:center}
.day-links a:hover{background:#2F63E8;color:#fff;border-color:#2F63E8}
.day-links a.primary{background:#2F63E8;color:#fff;border-color:#2F63E8}
.day-links a.primary:hover{background:#1E4BC4}
.dl-icon{width:11px;height:11px;margin-right:5px;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
</style>
"""

GH_ICON = '<svg class="dl-icon" viewBox="0 0 16 16"><path d="M6.5 2.5h7v7M13.5 2.5L6 10M4 4H2.5v9.5H12V12"/></svg>'

DAY_LINKS_HTML = {
    "06": (
        '<div class="day-links">\n'
        '  <a class="primary" href="day06_reading.html">Reading</a>\n'
        '  <a href="day06_python_mysql.html">MySQL Notebook</a>\n'
        '  <a href="day06_python_sqlite.html">SQLite Notebook</a>\n'
        f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/Day%2006" target="_blank" rel="noopener">{GH_ICON}Notebooks &amp; Exercises</a>\n'
        "</div>"
    ),
    "07": (
        '<div class="day-links">\n'
        '  <a class="primary" href="day07_reading.html">Reading</a>\n'
        f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/Day%2007" target="_blank" rel="noopener">{GH_ICON}Notebook Source</a>\n'
        "</div>"
    ),
}


def render_sidebar(active_day):
    parts = [
        '<button class="sidebar-toggle" aria-label="Toggle navigation" aria-expanded="false">&#9776;</button>',
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


def infer_active_day(path):
    m = re.search(r"Day[ %]?0?(\d+)", path)
    if not m:
        raise ValueError(f"can't infer day number from path: {path}")
    return f"{int(m.group(1)):02d}"


def inject(path):
    text = open(path, encoding="utf-8").read()
    if "site-sidebar" in text:
        print(f"{path}: sidebar already present, skipping (re-run nbconvert first to get a clean export)")
        return
    active_day = infer_active_day(path)
    text = text.replace("</head>", SIDEBAR_CSS + DAY_LINKS_CSS + "</head>", 1)
    text = re.sub(r"(<body[^>]*>)", r"\1\n" + render_sidebar(active_day), text, count=1)
    day_links = DAY_LINKS_HTML.get(active_day)
    if day_links:
        text = re.sub(
            r'(<div class="container" id="notebook-container">)',
            r"\1\n" + day_links,
            text, count=1,
        )
    text = text.replace("</body>", TOGGLE_JS + "</body>", 1)
    open(path, "w", encoding="utf-8").write(text)
    print(f"{path}: sidebar added (active day {active_day})")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        inject(p)
