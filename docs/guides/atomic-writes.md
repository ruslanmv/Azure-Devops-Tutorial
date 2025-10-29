# Guide: Atomic Writes

Atomic writes reduce the risk of partial files during crashes or concurrent writers.

## Pattern

1. Create a temporary file **in the same directory** as the target.
2. Write the full content to the temp file.
3. Replace (rename) the temp file onto the target (`os.replace`), which is atomic on most platforms.

## With `utils.fs`

```python
from utils.fs import atomic_write_text, atomic_write_bytes

atomic_write_text("reports/summary.txt", "Final content\n")
atomic_write_bytes("reports/data.bin", b"\x00\x01")
```

## Why Same Directory?

Replacing across filesystems may not be atomic. Using the same directory ensures the rename is atomic on POSIX and modern Windows.
