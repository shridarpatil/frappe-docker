# Frappe Docker Makefile
# Automatically handles app volume mounts - no need to edit docker-compose.yml

SHELL := /bin/bash
APPS_DIR := ./apps
OVERRIDE_FILE := docker-compose.override.yml

# Services that need app volume mounts
SERVICES := web-app default-worker long-worker short-worker scheduler socketio

# Database selection (default: mariadb)
DB ?= mariadb
PROFILES := --profile $(DB)

ifdef workers
	PROFILES += --profile workers
endif
ifdef socketio
	PROFILES += --profile socketio
endif

# Generate docker-compose.override.yml with volume mounts for all apps in ./apps/
.PHONY: generate-override
generate-override:
	@echo "services:" > $(OVERRIDE_FILE)
	@apps=$$(find $(APPS_DIR) -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -r -n1 basename); \
	for service in $(SERVICES); do \
		echo "  $$service:" >> $(OVERRIDE_FILE); \
		echo "    volumes:" >> $(OVERRIDE_FILE); \
		if [ -n "$$apps" ]; then \
			for app in $$apps; do \
				echo "      - ./apps/$$app:/home/frappe/frappe-bench/apps/$$app" >> $(OVERRIDE_FILE); \
			done; \
		else \
			echo "      []" >> $(OVERRIDE_FILE); \
		fi; \
		echo "" >> $(OVERRIDE_FILE); \
	done; \
	if [ -n "$$apps" ]; then \
		echo "Generated $(OVERRIDE_FILE) with apps: $$apps"; \
	else \
		echo "Generated $(OVERRIDE_FILE) with no apps"; \
	fi

# Development mode (with logs in foreground)
# Usage: make up dev=1 [workers=1] [socketio=1]
.PHONY: up
up: generate-override
ifdef prod
	@echo "Starting in production mode (all services, detached)..."
	docker compose --profile prod up -d
else ifdef dev
	@echo "Starting in dev mode (foreground)..."
	docker compose $(PROFILES) up
else
	@echo "Starting in detached mode..."
	docker compose $(PROFILES) up -d
endif

.PHONY: down
down:
	docker compose --profile prod --profile mariadb --profile postgres down

.PHONY: restart
restart: generate-override
	docker compose $(PROFILES) restart

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
	@echo "  make up                    - Start (detached, mariadb)"
	@echo "  make up dev=1              - Dev mode (with logs)"
	@echo "  make up db=postgres        - Use PostgreSQL"
	@echo "  make up db=mariadb         - Use MariaDB (default)"
	@echo "  make up workers=1          - Include workers + scheduler"
	@echo "  make up socketio=1         - Include socketio"
	@echo "  make up prod=1             - Production (all services)"
	@echo "  make up dev=1 workers=1    - Dev with workers"
	@echo "  make down                  - Stop all containers"
	@echo "  make restart               - Restart containers"
	@echo ""
	@echo "Utilities:"
	@echo "  make logs                  - Follow web-app logs"
	@echo "  make shell                 - Open bash in web-app"
	@echo "  make bench CMD='...'       - Run bench command"
	@echo "  make list-apps             - Show apps"
	@echo ""
	@echo "To add a new app:"
	@echo "  1. Clone/create app in ./apps/"
	@echo "  2. Add app name to sites/apps.txt"
	@echo "  3. Run: make up"
