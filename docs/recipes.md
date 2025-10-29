# Recipes

## 1) Save a Report Safely

```python
from utils.fs import safe_filename, ensure_dir, atomic_write_text
title = "Quarterly Report: Q3/2025 * DRAFT *"
fname = safe_filename(title) + ".md"
ensure_dir("reports")
atomic_write_text(f"reports/{fname}", "# Report\nAll good.\n")
```

## 2) Validate Upload Destination

```python
from utils.fs import resolve_under
upload_root = "/srv/uploads"
user_path = "userA/notes.txt"  # from form
dest = resolve_under(upload_root, user_path)  # ValueError if traversal
```

## 3) Schedule Length

```python
from utils.time import parse_minutes, format_minutes_compact

dur = parse_minutes("1h 45m")  # 105
print(format_minutes_compact(dur))  # "1h 45m"
```

## 4) Round Meeting Length to 15 Minutes

```python
from utils.time import ceil_to_increment
ceil_to_increment(51, 15)  # 60
```
