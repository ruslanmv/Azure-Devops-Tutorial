# Workshop Utils

Welcome to the documentation for **Workshop Utils** — a compact set of Python helpers for safe filesystem operations and time/duration handling.
These utilities are extracted from `workshop_builder` and designed to be dependency-light, well-tested, and easy to integrate.

## Features

- **Filesystem** (`utils.fs`)
  - `safe_filename()` — convert arbitrary strings into safe, cross-platform filenames.
  - `ensure_dir()` — idempotent directory creation.
  - `is_within_dir()` / `resolve_under()` — guard against path traversal.
  - `atomic_write_text()` / `atomic_write_bytes()` — safe atomic file writes.
  - `temp_dir()` — temporary directory context manager with cleanup.
- **Time** (`utils.time`)
  - `parse_minutes()` — parse human-friendly or ISO-8601-like durations.
  - `format_minutes_compact()` / `format_hhmm()` — human/clock formatting.
  - `hours_to_minutes()` / `minutes_to_hours_tuple()` — conversions.
  - `clamp_minutes()` / `ceil_to_increment()` — utility helpers.

## Quick Start

```bash
# 1) Install mkdocs (for browsing these docs locally)
pip install mkdocs

# 2) Serve the docs (from the directory with mkdocs.yml)
mkdocs serve

# 3) Open your browser at the URL shown (usually http://127.0.0.1:8000/)
```

> Tip: If you prefer a fancier look, you can install `mkdocs-material` and update the `theme` in `mkdocs.yml`:
>
> ```bash
> pip install mkdocs-material
> ```
>
> ```yaml
> theme:
>   name: material
> ```

## Project Structure (example)

```
your-project/
├─ src/
│  └─ utils/
│     ├─ __init__.py
│     ├─ fs.py
│     └─ time.py
├─ mkdocs.yml
└─ docs/
   └─ (these files)
```

## Audience

This documentation is intended for:
- Developers integrating the `utils.fs` and `utils.time` modules.
- Workshop authors who need safe file handling and robust time parsing.
- Reviewers and contributors.

---

Continue with **[Installation](installation.md)**.
