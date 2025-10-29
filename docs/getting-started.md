# Getting Started

This guide walks you through creating the `src/utils` modules using the provided shell script and using the utilities in a Python project.

## 1) Generate Files with the Script

Create the file `4.sh` and make it executable. **Use a quoted heredoc delimiter** to avoid shell expansion issues.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Creating src/utils directory..."
mkdir -p src/utils

echo "Creating src/utils/__init__.py..."
cat <<'EOF' > src/utils/__init__.py
# (content omitted here for brevity — see repo)
EOF

echo "Creating src/utils/fs.py..."
cat <<'EOF' > src/utils/fs.py
# (content omitted here for brevity — see repo)
EOF

echo "Creating src/utils/time.py..."
cat <<'EOF' > src/utils/time.py
# (content omitted here for brevity — see repo)
EOF

echo "All utility files have been created."
```

Then run:

```bash
chmod +x 4.sh
./4.sh
```

If you previously saw errors like `max_len: command not found`, it's because the heredoc was unquoted. Using `<<'EOF'` resolves this by preventing shell interpolation.

## 2) Verify Imports

```bash
export PYTHONPATH="$PWD/src:$PYTHONPATH"
python - <<'PY'
import utils.fs as fs
import utils.time as time
print("fs.safe_filename('Hello/World?.txt') ->", fs.safe_filename('Hello/World?.txt'))
print("time.parse_minutes('1h30m') ->", time.parse_minutes('1h30m'))
PY
```

## 3) Next Steps

- Read **[Usage](usage.md)** for practical examples.
- Dive into **[API Reference](api/fs.md)** and **[API Reference](api/time.md)** for details.
