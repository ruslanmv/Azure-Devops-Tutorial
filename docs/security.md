# Security Considerations

- Use `resolve_under()` to prevent directory traversal when combining user input with a base directory.
- Sanitize external input with `safe_filename()` before writing to disk.
- Prefer atomic writes to avoid partial file states that can be exploited in race conditions.
- Avoid leaking sensitive paths in error messages; catch and rethrow user-friendly messages where appropriate.
