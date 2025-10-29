# Contributing

Thanks for your interest!

## Dev Environment

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -U pip
pip install -e ".[dev]"  # if you have a setup.cfg/pyproject
```

## Style & Linting (suggested)

- Format with **black**
- Lint with **ruff**

```bash
pip install black ruff
black src tests
ruff check src tests
```

## Tests (suggested)

```bash
pip install pytest
pytest -q
```

## Docs

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```
