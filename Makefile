DOCKER_COMPOSE := docker compose
SERVICE := azdo-agent

PYTHON := python3
VENV := .venv
MKDOCS := $(VENV)/bin/mkdocs

.PHONY: help
help:
	@echo "Azure DevOps Tutorial - Commands"
	@printf "%-18s %s\n" \
	  "make env" "Create .env from template" \
	  "make build" "Build Docker image" \
	  "make up" "Start container" \
	  "make down" "Stop container" \
	  "make restart" "Restart container" \
	  "make logs" "Tail logs" \
	  "make ps" "List containers" \
	  "make ssh" "SSH into devops@localhost:2222" \
	  "make rebuild" "Rebuild image (no cache)" \
	  "make clean" "Down + remove volumes" \
	  "make fresh" "Clean + remove _agent_* folders" \
	  "make docs-install" "Install MkDocs (venv)" \
	  "make docs-serve" "Serve docs at http://127.0.0.1:8000" \
	  "make docs-build" "Build static docs" \
	  "make docs-clean" "Remove venv and site"

.PHONY: env
env:
	@if [ ! -f .env ]; then cp .env.example .env && echo "Created .env from .env.example"; else echo ".env exists"; fi

.PHONY: build
build: env
	$(DOCKER_COMPOSE) build

.PHONY: up
up: env
	$(DOCKER_COMPOSE) up -d
	@echo "SSH: ssh devops@localhost -p 2222"

.PHONY: down
down:
	$(DOCKER_COMPOSE) down

.PHONY: restart
restart: down up

.PHONY: logs
logs:
	$(DOCKER_COMPOSE) logs -f $(SERVICE)

.PHONY: ps
ps:
	$(DOCKER_COMPOSE) ps

.PHONY: ssh
ssh:
	ssh devops@localhost -p 2222

.PHONY: rebuild
rebuild: env
	$(DOCKER_COMPOSE) build --no-cache

.PHONY: clean
clean:
	$(DOCKER_COMPOSE) down -v || true

.PHONY: fresh
fresh: clean
	rm -rf _agent_work _agent_logs || true

# Docs
.PHONY: docs-install
docs-install:
	@if [ ! -d $(VENV) ]; then $(PYTHON) -m venv $(VENV); fi
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install mkdocs mkdocs-material

.PHONY: docs-serve
docs-serve: docs-install
	$(MKDOCS) serve -a 127.0.0.1:8000

.PHONY: docs-build
docs-build: docs-install
	$(MKDOCS) build

.PHONY: docs-clean
docs-clean:
	rm -rf $(VENV) site
