# Docker Compose command
DOCKER_COMPOSE := docker compose

# Service name from docker-compose.yml
SERVICE := azdo-agent

# Python and virtual environment (for optional docs)
PYTHON := python3
VENV := .venv
MKDOCS := $(VENV)/bin/mkdocs

# Default target: show help
.PHONY: help
help:
    @echo "Azure DevOps Tutorial - Available Commands"
    @echo "==========================================="
    @echo
    @printf "%-16s %s\n" \
      "make env" "Create .env file from template (required first step)" \
      "make build" "Build the Docker image" \
      "make up" "Start container in background" \
      "make down" "Stop and remove container" \
      "make restart" "Restart the container" \
      "make logs" "Tail logs from the agent" \
      "make ps" "Show running containers" \
      "make ssh" "SSH into the container (devops@localhost:2222)" \
      "make rebuild" "Force rebuild without cache" \
      "make clean" "Stop container and remove volumes" \
      "make fresh" "Complete reset (clean + delete work directories)" \
      "make docs-install" "Install MkDocs for documentation" \
      "make docs-serve" "Serve docs at http://127.0.0.1:8000" \
      "make docs-build" "Build static documentation" \
      "make docs-clean" "Remove documentation environment"
    @echo

# ============================================
# Core Docker Commands
# ============================================

# Create .env from template if it doesn't exist
.PHONY: env
env:
    @if [ ! -f .env ]; then \
        cp .env.example .env && \
        echo "✓ Created .env from .env.example"; \
        echo "⚠️  IMPORTANT: Edit .env and add your Azure DevOps credentials!"; \
    else \
        echo "✓ .env file already exists"; \
    fi

# Build the Docker image
.PHONY: build
build: env
    @echo "Building DevOps Box image..."
    $(DOCKER_COMPOSE) build

# Start container in background
.PHONY: up
up: env
    @echo "Starting DevOps Box..."
    $(DOCKER_COMPOSE) up -d
    @echo "✓ DevOps Box is running!"
    @echo "  - Check status: make ps"
    @echo "  - View logs: make logs"
    @echo "  - SSH access: make ssh"

# Stop and remove container
.PHONY: down
down:
    @echo "Stopping DevOps Box..."
    $(DOCKER_COMPOSE) down
    @echo "✓ DevOps Box stopped"

# Restart container
.PHONY: restart
restart: down up

# Tail logs (Ctrl+C to exit)
.PHONY: logs
logs:
    @echo "Showing logs (Ctrl+C to exit)..."
    $(DOCKER_COMPOSE) logs -f $(SERVICE)

# Show container status
.PHONY: ps
ps:
    $(DOCKER_COMPOSE) ps

# SSH into the container
.PHONY: ssh
ssh:
    @echo "Connecting via SSH (password from .env)..."
    @echo "Default password: changeMe123"
    ssh devops@localhost -p 2222

# Force rebuild without cache
.PHONY: rebuild
rebuild: env
    @echo "Rebuilding from scratch (no cache)..."
    $(DOCKER_COMPOSE) build --no-cache

# Clean: stop and remove volumes
.PHONY: clean
clean:
    @echo "Cleaning up containers and volumes..."
    $(DOCKER_COMPOSE) down -v || true
    @echo "✓ Cleanup complete"

# Fresh start: clean everything including work directories
.PHONY: fresh
fresh: clean
    @echo "Removing agent work and log directories..."
    rm -rf _agent_work _agent_logs || true
    @echo "✓ Fresh start - all data removed"

# ============================================
# Documentation Commands (Optional)
# ============================================

.PHONY: docs-install
docs-install:
    @echo "Setting up documentation environment..."
    @if [ ! -d $(VENV) ]; then $(PYTHON) -m venv $(VENV); fi
    $(VENV)/bin/pip install --upgrade pip
    $(VENV)/bin/pip install mkdocs mkdocs-material
    @echo "✓ Documentation tools installed"

.PHONY: docs-serve
docs-serve: docs-install
    @echo "Starting documentation server at http://127.0.0.1:8000"
    $(MKDOCS) serve -a 127.0.0.1:8000

.PHONY: docs-build
docs-build: docs-install
    @echo "Building documentation..."
    $(MKDOCS) build
    @echo "✓ Documentation built in ./site directory"

.PHONY: docs-clean
docs-clean:
    @echo "Removing documentation environment..."
    rm -rf $(VENV) site
    @echo "✓ Documentation cleanup complete"