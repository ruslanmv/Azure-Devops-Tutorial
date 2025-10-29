# Installation

## Requirements
- Python 3.9+ (recommended)
- `pip` or `pipx`

## Install for a Project

Assuming your project uses the `src/` layout and contains `src/utils/fs.py` and `src/utils/time.py`:

```bash
# Add the src directory to your PYTHONPATH in development
export PYTHONPATH="$PWD/src:$PYTHONPATH"

# Verify imports
python -c "import utils.fs, utils.time; print('OK')"
```

Alternatively, if this is part of a package, install it in editable mode:

```bash
pip install -e .
```

## Installing MkDocs (for this documentation)

```bash
pip install mkdocs
# optional (nice theme)
pip install mkdocs-material
```

## Serving the Docs

```bash
# From the directory containing mkdocs.yml
mkdocs serve
```

## Building Static Docs

```bash
mkdocs build
# Output will be in the site/ directory
```
