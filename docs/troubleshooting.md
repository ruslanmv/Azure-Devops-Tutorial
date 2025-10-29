# Troubleshooting

## Shell heredoc errors like `max_len: command not found`

**Cause**: Unquoted heredoc (`<< EOF`) allows shell expansion; parts of your Python are interpreted as commands.

**Fix**: Use a **quoted** delimiter: `<<'EOF'` (single quotes).

```bash
cat <<'EOF' > src/utils/fs.py
# ...python content here...
EOF
```

## `PermissionError` during atomic writes

Ensure the target directory is writable and on a filesystem that supports `os.replace` semantics.

## Path traversal blocked

`resolve_under()` raises `ValueError` when a path escapes the base. This is expected and protects your system.
