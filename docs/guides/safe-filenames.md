# Guide: Safe Filenames

When accepting user input for filenames, assume it may contain path separators, control characters, or reserved names.

## Principles

- **Normalize**: use Unicode NFKD and keep only printable characters.
- **No separators**: convert `/` and `\` to spaces.
- **Whitelist**: allow `[A-Za-z0-9._\- ]` and replace everything else with `_`.
- **Reserved names**: on Windows, avoid `con`, `prn`, `aux`, `nul`, `com1..9`, `lpt1..9`.
- **Length**: cap length (`max_len`) and preserve extensions when possible.

## Example

```python
from utils.fs import safe_filename
safe = safe_filename("../../Résumé?.pdf")
print(safe)  # "__Resume.pdf"
```
