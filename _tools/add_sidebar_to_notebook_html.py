"""
Injects the course-wide sidebar nav (and its mobile hamburger toggle) into a
Day 06/07 notebook's nbconvert HTML export, plus a day-links button row
matching the one on that day's reading page (same buttons everywhere for a
given day -- Reading, its worked/notebook page(s), a single GitHub link --
with whichever page you're on shown as the active button).

nbconvert has no notion of this course's site chrome, so none of this can
live in the notebook source -- it's added as a post-processing pass after
every `jupyter nbconvert --to html` run. Re-run this whenever a notebook is
reconverted (day06_python_mysql.html, day06_python_sqlite.html,
day06_exercises.html, day06_exercises_solutions.html, project_07_exercises.html,
project_07_solutions.html all need it).

Usage:
    python _tools/add_sidebar_to_notebook_html.py "Day 06/day06_python_mysql.html" [...]
"""

import os
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
:root{--ink:#141414;--blue:#2F63E8;--blue-dark:#1E4BC4;--gray:#5B6472;--gray-muted:#9CA3AF;--border:#E5E7EB;--panel:#F3F4F6;--card-bg:#FFFFFF;--paper:#FAFBFC}
:root[data-theme="dark"]{--ink:#E7E9EC;--blue:#4C8DFF;--blue-dark:#9DBBFF;--gray:#A6ADB8;--gray-muted:#767D89;--border:#2A2E37;--panel:#191C22;--card-bg:#1A1D23;--paper:#101216}
@media(prefers-color-scheme:dark){:root:not([data-theme="light"]){--ink:#E7E9EC;--blue:#4C8DFF;--blue-dark:#9DBBFF;--gray:#A6ADB8;--gray-muted:#767D89;--border:#2A2E37;--panel:#191C22;--card-bg:#1A1D23;--paper:#101216}}
.site-sidebar{position:fixed;top:0;left:0;bottom:0;width:220px;background:var(--panel);border-right:1px solid var(--border);padding:22px 0;overflow-y:auto;z-index:1000}
.site-sidebar .brand{font-family:Georgia,serif;font-weight:800;font-size:14.5px;color:var(--ink);padding:0 20px 16px;border-bottom:1px solid var(--border);margin-bottom:8px;line-height:1.3}
.site-sidebar a{display:block;padding:9px 20px;font-family:-apple-system,'Segoe UI',sans-serif;font-size:14px;color:var(--gray);text-decoration:none;border-left:3px solid transparent}
.site-sidebar a:hover{background:var(--card-bg);color:var(--blue)}
.site-sidebar a.active{background:var(--card-bg);color:var(--blue);font-weight:700;border-left-color:var(--blue)}
.site-sidebar .daynum{font-family:monospace;font-size:10.5px;color:var(--gray-muted);display:block;letter-spacing:.08em;text-transform:uppercase;margin-bottom:1px}
.site-sidebar a.active .daynum{color:var(--blue)}
body{margin-left:220px;background:var(--paper)}
.sidebar-toggle{display:none;position:fixed;top:14px;left:14px;z-index:1200;width:40px;height:40px;border-radius:8px;border:1px solid var(--border);background:var(--card-bg);color:var(--ink);font-size:18px;line-height:1;cursor:pointer;box-shadow:0 2px 8px rgba(20,20,30,.08);align-items:center;justify-content:center}
.sidebar-backdrop{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:900}
.theme-toggle{position:fixed;top:14px;right:20px;z-index:1200;width:40px;height:40px;border-radius:8px;border:1px solid var(--border);background:var(--card-bg);color:var(--ink);cursor:pointer;box-shadow:0 2px 8px rgba(20,20,30,.08);display:flex;align-items:center;justify-content:center}
.theme-toggle svg{width:18px;height:18px;stroke:currentColor;stroke-width:1.8;fill:none;stroke-linecap:round;stroke-linejoin:round}
.theme-toggle .icon-moon{display:none}
:root[data-theme="dark"] .theme-toggle .icon-sun{display:none}
:root[data-theme="dark"] .theme-toggle .icon-moon{display:block}
@media(prefers-color-scheme:dark){:root:not([data-theme="light"]) .theme-toggle .icon-sun{display:none} :root:not([data-theme="light"]) .theme-toggle .icon-moon{display:block}}
:root[data-theme="light"] .theme-toggle .icon-sun{display:block}
:root[data-theme="light"] .theme-toggle .icon-moon{display:none}
@media(max-width:900px){
.site-sidebar{width:250px;transform:translateX(-100%);transition:transform .25s ease;box-shadow:2px 0 16px rgba(0,0,0,.18)}
.site-sidebar.open{transform:translateX(0)}
.sidebar-toggle{display:flex}
.sidebar-backdrop.open{display:block}
body{margin-left:0}
}
</style>
"""

ANTI_FLASH_SCRIPT = """<script>
(function(){
  try{
    var saved = localStorage.getItem('theme');
    if(saved === 'dark' || saved === 'light'){
      document.documentElement.setAttribute('data-theme', saved);
    }
  }catch(e){}
})();
</script>
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
<script>
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
</script>
"""

DAY_LINKS_CSS = """<style>
.day-links{display:flex;gap:10px;flex-wrap:wrap;margin:16px 0 22px}
.day-links a{font-family:monospace;font-size:12.5px;font-weight:700;text-decoration:none;color:var(--blue-dark);background:var(--panel);border:1px solid var(--border);border-radius:6px;padding:6px 11px;display:inline-flex;align-items:center}
.day-links a:hover{background:var(--blue);color:#fff;border-color:var(--blue)}
.day-links a.primary{background:var(--blue);color:#fff;border-color:var(--blue)}
.day-links a.primary:hover{background:var(--blue-dark)}
.dl-icon{width:11px;height:11px;margin-right:5px;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
</style>
"""

THEME_TOGGLE_BUTTON = """<button class="theme-toggle" aria-label="Toggle dark mode">
  <svg class="icon-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>
  <svg class="icon-moon" viewBox="0 0 24 24"><path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5z"/></svg>
</button>
"""

GH_ICON = '<svg class="dl-icon" viewBox="0 0 16 16"><path d="M6.5 2.5h7v7M13.5 2.5L6 10M4 4H2.5v9.5H12V12"/></svg>'


def _link(href, label, active):
    cls = ' class="primary"' if active else ""
    return f'  <a{cls} href="{href}">{label}</a>\n'


def render_day_links_for(basename):
    """Same button row on every page belonging to a day: Reading, its worked/
    notebook page(s), one GitHub link -- whichever page `basename` is gets the
    active (highlighted) style."""
    if basename in ("day06_reading.html", "day06_python_mysql.html", "day06_python_sqlite.html"):
        html = '<div class="day-links">\n'
        html += _link("day06_reading.html", "Reading", basename == "day06_reading.html")
        html += _link("day06_python_mysql.html", "MySQL Notebook", basename == "day06_python_mysql.html")
        html += _link("day06_python_sqlite.html", "SQLite Notebook", basename == "day06_python_sqlite.html")
        html += f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/Day%2006" target="_blank" rel="noopener">{GH_ICON}View on GitHub</a>\n'
        html += "</div>"
        return html
    if basename in ("day07_reading.html", "project_07_solutions.html"):
        html = '<div class="day-links">\n'
        html += _link("day07_reading.html", "Reading", basename == "day07_reading.html")
        html += _link("project_07_solutions.html", "Worked Examples", basename == "project_07_solutions.html")
        html += f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/Day%2007" target="_blank" rel="noopener">{GH_ICON}View on GitHub</a>\n'
        html += "</div>"
        return html
    # day06_exercises.html, day06_exercises_solutions.html, project_07_exercises.html:
    # practice-only pages, not part of the Reading <-> Worked Examples pair --
    # same row as their day, nothing marked active since none of these three
    # buttons is the page itself.
    if basename in ("day06_exercises.html", "day06_exercises_solutions.html"):
        html = '<div class="day-links">\n'
        html += _link("day06_reading.html", "Reading", False)
        html += _link("day06_python_mysql.html", "MySQL Notebook", False)
        html += _link("day06_python_sqlite.html", "SQLite Notebook", False)
        html += f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/Day%2006" target="_blank" rel="noopener">{GH_ICON}View on GitHub</a>\n'
        html += "</div>"
        return html
    if basename == "project_07_exercises.html":
        html = '<div class="day-links">\n'
        html += _link("day07_reading.html", "Reading", False)
        html += _link("project_07_solutions.html", "Worked Examples", False)
        html += f'  <a href="https://github.com/a7madmostafa/sql-for-data-analysis/tree/main/Day%2007" target="_blank" rel="noopener">{GH_ICON}View on GitHub</a>\n'
        html += "</div>"
        return html
    return None


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
    basename = os.path.basename(path)
    text = text.replace("<title>", ANTI_FLASH_SCRIPT + "<title>", 1)
    text = text.replace("</head>", SIDEBAR_CSS + DAY_LINKS_CSS + "</head>", 1)
    day_links = render_day_links_for(basename) or ""
    text = re.sub(r"(<body[^>]*>)", r"\1\n" + render_sidebar(active_day) + "\n" + day_links, text, count=1)
    text = text.replace("</body>", TOGGLE_JS + "</body>", 1)
    open(path, "w", encoding="utf-8").write(text)
    print(f"{path}: sidebar added (active day {active_day})")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        inject(p)
