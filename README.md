<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>
# frappe-docker
Dockerizing frappe for development and production

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

```bash
# Clone the repo
git clone git@github.com:shridarpatil/frappe-docker.git
cd frappe-docker

# Pull docker image
docker pull shridh0r/frappe:develop

# Start in dev mode (with logs)
./bench-docker up --dev

# Create a new site
./bench-docker shell
bench new-site site1.local --force --db-root-password root
```

## CLI Usage

Use `./bench-docker` to manage containers:

### Start Containers

```bash
./bench-docker up                     # Start detached (web-app only)
./bench-docker up --dev               # Dev mode with logs (foreground)
./bench-docker up --workers           # Include background workers + scheduler
./bench-docker up --socketio          # Include socketio
./bench-docker up --prod              # Production (all services)
./bench-docker up --dev --workers     # Dev mode with workers
```

### Other Commands

```bash
./bench-docker down                   # Stop all containers
./bench-docker restart                # Restart containers
./bench-docker logs                   # Follow web-app logs
./bench-docker shell                  # Open bash in web-app container
./bench-docker bench migrate          # Run bench commands
./bench-docker bench build            # Build assets
./bench-docker list-apps              # Show installed apps
./bench-docker help                   # Show all commands
```

## Adding a New App

No need to edit `docker-compose.yml` - apps are auto-discovered!

1. Clone/create your app in `./apps/` folder:
   ```bash
   cd apps
   git clone https://github.com/your/app.git my_app
   ```

2. Add app name to `sites/apps.txt`:
   ```bash
   echo "my_app" >> sites/apps.txt
   ```

3. Restart:
   ```bash
   ./bench-docker up --dev
   ```

4. Install app on your site:
   ```bash
   ./bench-docker shell
   bench --site site1.local install-app my_app
   ```

## Services

| Service | Profile | Description |
|---------|---------|-------------|
| web-app | (always) | Main Frappe web server |
| redis | (always) | Cache and queue backend |
| db | (always) | MariaDB database |
| nginx | (always) | Reverse proxy |
| default-worker | `--workers` | Background job worker (default queue) |
| long-worker | `--workers` | Background job worker (long queue) |
| short-worker | `--workers` | Background job worker (short queue) |
| scheduler | `--workers` | Job scheduler |
| socketio | `--socketio` | Real-time updates |

## Building Custom Image

```bash
docker-compose build
```

### Build Args

| Arg | Description |
|-----|-------------|
| FRAPPE_PATH | Frappe repo URL |
| FRAPPE_BRANCH | Frappe branch name |
| FRAPPE_PYTHON | Python version |
| BENCH_PATH | Bench repo URL |
| BENCH_BRANCH | Bench branch name |

Example:
```bash
docker-compose build \
  --build-arg FRAPPE_PATH=https://github.com/zerodhatech/frappe.git \
  --build-arg FRAPPE_BRANCH=zero_v12
```

## Create Site

```bash
# MariaDB
./bench-docker shell
bench new-site site1.local --force --db-root-password root

# PostgreSQL (if using postgres)
bench new-site site1.local --force --db-type postgres --db-root-username postgres --db-root-password root
```

## Project Structure

```
frappe-docker/
├── apps/                    # App source code (auto-mounted)
│   ├── frappe/
│   └── your_app/
├── sites/
│   ├── apps.txt             # List of apps to install
│   ├── apps.json            # App metadata
│   └── site1.local/         # Site data
├── docker-compose.yml       # Service definitions
├── bench-docker             # CLI wrapper
├── Makefile                 # Build automation
└── run.sh                   # Container startup script
```
