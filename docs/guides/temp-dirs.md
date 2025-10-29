# Guide: Temporary Directories

Use `temp_dir()` to create an isolated workspace that's cleaned up automatically.

```python
from utils.fs import temp_dir, ensure_dir

with temp_dir(prefix="job_") as work:
    ensure_dir(work / "output")
    (work / "output" / "result.txt").write_text("ok")
# `work` is removed on exit (best-effort)
```
