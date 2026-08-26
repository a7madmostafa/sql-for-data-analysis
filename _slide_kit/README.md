# _slide_kit

Shared `.pptx` slide-deck builder used by every `Slides_0N/build.py` in this course. One design
system (colors, layout primitives, code-block styling) lives here once instead of being redone
per day.

## Usage

```python
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "_slide_kit"))
from deckkit import Deck

deck = Deck()
deck.title_slide(eyebrow, title, subtitle, footer)
deck.agenda_slide(eyebrow, title, subtitle, [(num, heading, desc), ...])
deck.cards_slide(eyebrow, title, subtitle, [(heading, desc), ...], panel_title=None, panel_lines=None)
deck.grid_slide(eyebrow, title, subtitle, [(heading, desc), ...], columns=2, accent_numbers=False)
deck.code_slide(eyebrow, title, subtitle, filename, code_lines, notes=[(heading, desc), ...])
deck.closing_slide(eyebrow, title, subtitle)
deck.save("Day 0N - Topic.pptx")
```

`code_slide`'s `code_lines` accepts plain SQL strings — a small built-in tokenizer colors
keywords/functions/strings/comments automatically (see `_KEYWORDS`/`_FUNCS` in `deckkit.py`; add
to those sets if a new day's SQL uses something not yet recognized).

## Fonts

The design matches a reference deck sampled directly from its PDF (exact hex colors and font
names extracted via PyMuPDF). Three free Google Fonts, already installed for the current Windows
user on this machine (per-user install — copied into `%LOCALAPPDATA%\Microsoft\Windows\Fonts` with
matching registry entries, no admin rights needed):

- **Bricolage Grotesque** (headings) — variable font upstream; installed here as static
  Regular/Bold instances (`fonttools varLib.instancer`, pinned at `opsz=14`) so PowerPoint treats
  them as a normal bold-capable family instead of defaulting to the font's 96pt/ExtraBold instance.
- **Nunito Sans** (body text) — same variable-font-to-static treatment, Regular/Bold/Italic.
- **IBM Plex Mono** (eyebrows, code, page numbers) — ships as static weights already; used as-is.

Without these fonts installed, PowerPoint substitutes a default sans/mono and the deck still looks
correct (verified) — layout, colors, and hierarchy don't depend on the exact typeface, just the
polish does. To install on another machine: download each family from Google Fonts and install
normally, or re-run the same `varLib.instancer` conversion for Bricolage Grotesque / Nunito Sans if
you want the same Regular/Bold-only static treatment used here.

## Rendering previews

There's no PDF/image export in `deckkit.py` itself. To eyeball a build during development (Windows
+ PowerPoint installed):

```python
import win32com.client, os
app = win32com.client.Dispatch("PowerPoint.Application")
app.Visible = True
pres = app.Presentations.Open(os.path.abspath("Day 0N - Topic.pptx"), WithWindow=False)
pres.SaveAs(os.path.abspath("render_preview"), 17)  # 17 = ppSaveAsPNG, one PNG per slide
pres.Close(); app.Quit()
```
Delete the preview folder afterward — it's a scratch artifact, not part of the deliverable.
