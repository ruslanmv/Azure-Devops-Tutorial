# API — `utils.fs`

Filesystem helpers focused on safety and portability.

## `safe_filename(name: str, max_len: int = 120, keep_extension: bool = True) -> str`

Sanitize `name` into a cross-platform filename.

- Normalizes Unicode (NFKD) and strips control chars.
- Replaces path separators with spaces.
- Removes invalid characters with `_` (conservative allowlist).
- Avoids Windows reserved basenames (`con`, `prn`, `aux`, `nul`, `com1`..`com9`, `lpt1`..`lpt9`).
- Optionally preserves the last extension.
- Trims to `max_len` safely, keeping the extension when possible.

**Examples**:

```python
safe_filename("résumé.txt")               # "resume.txt" (accent folded by NFKD)
safe_filename("../../etc/passwd")         # "__etc_passwd"
safe_filename("CON")                      # "CON_file"
safe_filename("video.reallylongext", max_len=10)  # extension may be dropped if too long
```

## `ensure_dir(p: Path | str) -> Path`

Create directory recursively if needed (idempotent). Returns a `Path`.

## `is_within_dir(base_dir: Path | str, candidate: Path | str) -> bool`

`True` if `candidate` resolves within `base_dir` (prevents traversal).

## `resolve_under(base_dir: Path | str, relative: Path | str, must_exist: bool = False) -> Path`

Resolve a path under a base directory; raises `ValueError` if it escapes the base.
If `must_exist=True`, raises `FileNotFoundError` when missing.

```python
resolve_under("/safe", "../escape.txt")  # ValueError
```

## `atomic_write_text(path: Path | str, data: str, encoding: str = "utf-8") -> Path`

Atomically write text: write to a temp file in the same directory and replace.

## `atomic_write_bytes(path: Path | str, data: bytes) -> Path`

Atomically write bytes: write to a temp file in the same directory and replace.

## `remove_tree(path: Path | str) -> None`

Best-effort recursive directory deletion using `shutil.rmtree`.

## `temp_dir(prefix: str = "wb_", base: Optional[Path | str] = None) -> Iterator[Path]`

Context manager creating a temporary directory, with cleanup on exit.

```python
from utils.fs import temp_dir

with temp_dir(prefix="session_") as p:
    (p / "file.txt").write_text("demo")
# p is removed on exit
```
