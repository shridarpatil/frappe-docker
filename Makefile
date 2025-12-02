# Frappe Docker Makefile
# Automatically handles app volume mounts - no need to edit docker-compose.yml

SHELL := /bin/bash
APPS_DIR := ./apps
OVERRIDE_FILE := docker-compose.override.yml

# Services that need app volume mounts
SERVICES := web-app default-worker long-worker short-worker scheduler socketio

# Generate docker-compose.override.yml with volume mounts for all apps in ./apps/
.PHONY: generate-override
generate-override:
	@echo "version: '3.8'" > $(OVERRIDE_FILE)
	@echo "" >> $(OVERRIDE_FILE)
	@echo "services:" >> $(OVERRIDE_FILE)
	@for service in $(SERVICES); do \
		echo "  $$service:" >> $(OVERRIDE_FILE); \
		echo "    volumes:" >> $(OVERRIDE_FILE); \
		for app in $$(ls -d $(APPS_DIR)/*/ 2>/dev/null | xargs -n1 basename); do \
			echo "      - ./apps/$$app:/home/frappe/frappe-bench/apps/$$app" >> $(OVERRIDE_FILE); \
		done; \
		echo "" >> $(OVERRIDE_FILE); \
	done
	@echo "Generated $(OVERRIDE_FILE) with apps: $$(ls -d $(APPS_DIR)/*/ 2>/dev/null | xargs -n1 basename | tr '\n' ' ')"

# Development mode (web-app only, no workers)
.PHONY: up
up: generate-override
	docker compose up -d

.PHONY: up-logs
up-logs: generate-override
	docker compose up

# With workers (default, long, short workers + scheduler)
.PHONY: up-workers
up-workers: generate-override
	docker compose --profile workers up -d

# With socketio
.PHONY: up-socketio
up-socketio: generate-override
	docker compose --profile socketio up -d

# Production mode (all services: workers + socketio)
.PHONY: up-prod
up-prod: generate-override
	docker compose --profile prod up -d

.PHONY: down
down:
	docker compose --profile prod down

.PHONY: restart
restart: generate-override
	docker compose restart

.PHONY: logs
logs:
	docker compose logs -f web-app

.PHONY: shell
shell:
	docker compose exec web-app bash

.PHONY: bench
bench:
	docker compose exec web-app bench $(CMD)

.PHONY: list-apps
list-apps:
	@echo "Apps in ./apps/:"
	@ls -d $(APPS_DIR)/*/ 2>/dev/null | xargs -n1 basename
	@echo ""
	@echo "Apps in sites/apps.txt:"
	@cat sites/apps.txt

.PHONY: help
help:
	@echo "Frappe Docker Commands:"
	@echo ""
	@echo "Start/Stop:"
	@echo "  make up           - Dev mode (web-app only)"
	@echo "  make up-workers   - With background workers + scheduler"
	@echo "  make up-socketio  - With socketio"
	@echo "  make up-prod      - Production (all services)"
	@echo "  make down         - Stop all containers"
	@echo "  make restart      - Restart containers"
	@echo ""
	@echo "Utilities:"
	@echo "  make logs         - Follow web-app logs"
	@echo "  make shell        - Open bash in web-app"
	@echo "  make bench CMD='' - Run bench command"
	@echo "  make list-apps    - Show apps"
	@echo ""
	@echo "To add a new app:"
	@echo "  1. Clone/create app in ./apps/"
	@echo "  2. Add app name to sites/apps.txt"
	@echo "  3. Run: make up"
