# Usage

## Filesystem Helpers (`utils.fs`)

### Safe Filenames

```python
from utils.fs import safe_filename

print(safe_filename("My*Fancy:Report?.pdf"))
# -> "My_Fancy_Report.pdf"
```

### Idempotent Directories

```python
from utils.fs import ensure_dir
ensure_dir("artifacts/logs")  # creates parents if needed
```

### Path Traversal Guards

```python
from utils.fs import is_within_dir, resolve_under

base = "/srv/uploads"
user_rel = "../../etc/passwd"  # malicious
try:
    path = resolve_under(base, user_rel)
except ValueError:
    print("Blocked path traversal")
```

### Atomic Writes

```python
from utils.fs import atomic_write_text, atomic_write_bytes

atomic_write_text("output/report.txt", "Hello!")
atomic_write_bytes("output/data.bin", b"\x00\x01")
```

### Temporary Directories

```python
from utils.fs import temp_dir

with temp_dir(prefix="demo_") as tmp:
    print(f"Working in: {tmp}")
    # write files in tmp
# tmp is cleaned up automatically
```

## Time Helpers (`utils.time`)

```python
from utils.time import (
    parse_minutes, format_minutes_compact, format_hhmm,
    hours_to_minutes, minutes_to_hours_tuple,
    clamp_minutes, ceil_to_increment,
)

print(parse_minutes("1:30"))             # 90
print(parse_minutes("PT1H30M"))          # 90
print(format_minutes_compact(95))        # "1h 35m"
print(format_hhmm(95))                   # "01:35"
print(hours_to_minutes(2.25))            # 135
print(minutes_to_hours_tuple(135))       # (2, 15)
print(clamp_minutes(500, 0, 240))        # 240
print(ceil_to_increment(53, 15))         # 60
```
