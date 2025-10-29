# Azure DevOps Tutorial — Zero‑to‑Expert

This workshop teaches you how to:

- Run a **self‑hosted agent** inside a single Docker container (the **DevOps Box**) with SSH access.

- Split a monorepo (**HDP**) into **two Azure Repos** while preserving history.

- Build **modern pipelines** with path filters, branch policies, and secure-by-default settings.


## How to use these docs

Follow the **Labs** in order. In a terminal from the repo root:

```bash

cp .env.example .env   # set your values

make up                # start the DevOps Box

make docs-serve        # open docs at http://127.0.0.1:8000

```

> Your Azure DevOps org remains your normal web URL — the container only registers as an agent so jobs can land on it.

