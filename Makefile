# Root Makefile: container operations + MkDocs docs site
DOCKER_COMPOSE := docker compose
SERVICE := azdo-agent
PYTHON := python3
VENV := .venv
MKDOCS := $(VENV)/bin/mkdocs

.PHONY: help build up down restart logs ps ssh rebuild clean fresh env \
        docs-install docs-serve docs-build docs-clean

help:
	@echo "Usage: make <target>"; \
	echo; \
	printf "%-16s %s\n" \
	  build        "Build image(s)" \
	  up           "Start container in background (build if needed)" \
	  down         "Stop and remove container(s)" \
	  restart      "Restart the container" \
	  logs         "Tail logs from the agent container" \
	  ps           "List containers" \
	  ssh          "SSH into devops@localhost -p 2222" \
	  rebuild      "Force a no-cache rebuild" \
	  clean        "Down + remove volumes" \
	  fresh        "Clean + delete _agent_* folders" \
	  env          "Create .env from .env.example if missing" \
	  docs-install "Create venv & install MkDocs (Material)" \
	  docs-serve   "Serve docs locally at http://127.0.0.1:8000" \
	  docs-build   "Build static docs into ./site" \
	  docs-clean   "Remove venv and site build"; \
	echo

env:
	@test -f .env || (cp .env.example .env && echo "Created .env from .env.example")

build: env
	$(DOCKER_COMPOSE) build

up: env
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

restart: down up

logs:
	$(DOCKER_COMPOSE) logs -f $(SERVICE)

ps:
	$(DOCKER_COMPOSE) ps

ssh:
	ssh devops@localhost -p 2222

rebuild: env
	$(DOCKER_COMPOSE) build --no-cache

clean:
	$(DOCKER_COMPOSE) down -v || true

fresh: clean
	rm -rf _agent_work _agent_logs || true

# ---------- Docs ----------
docs-install:
	@if [ ! -d $(VENV) ]; then $(PYTHON) -m venv $(VENV); fi
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install mkdocs mkdocs-material

docs-serve: docs-install
	$(MKDOCS) serve -a 127.0.0.1:8000

docs-build: docs-install
	$(MKDOCS) build

docs-clean:
	rm -rf $(VENV) site
