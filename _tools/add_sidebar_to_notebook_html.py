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


def render_sidebar(active_day="06"):
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


def inject(path):
    text = open(path, encoding="utf-8").read()
    if "site-sidebar" in text:
        print(f"{path}: sidebar already present, skipping (re-run nbconvert first to get a clean export)")
        return
    text = text.replace("</head>", SIDEBAR_CSS + "</head>", 1)
    text = re.sub(r"(<body[^>]*>)", r"\1\n" + render_sidebar(), text, count=1)
    text = text.replace("</body>", TOGGLE_JS + "</body>", 1)
    open(path, "w", encoding="utf-8").write(text)
    print(f"{path}: sidebar added")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        inject(p)
