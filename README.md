# Frappe-Docker

Dockerizing frappe for production.

### Prerequisites:

- Install [Docker](https://docs.docker.com/install/)
- Install [Docker Compose](https://docs.docker.com/compose/install/)

Once docker and docker compose are installed, please follow the below steps.

1. Build the image.

   Using docker command: `docker-compose build --build-arg FRAPPE_PATH=https://github.com/zerodhatech/frappe.git --build-arg FRAPPE_BRANCH=<branch_name> .`

   Using docker-compose: `docker-compose build`

   This is assuming you are running build from same directory as Dockerfile.

   More on [build phase](#build-phase).

2. Run the image.

   using docker-compose: `docker-compose up`

   More on [run phase](#run-phase).

The image is also present at [Dockerhub](https://hub.docker.com/r/shridh0r/python-ubuntu) which can be pulled and executed.

### Creating site

The frappe container created from above will not have sites folder yet. Inorder to create a site, execute the startup script as `/bin/sh start_up.sh new_site <arguments>`.

The idea here is sites folder in frappe setup is a one time task and should not be executed everytime the image is built.

Hence the creation of site part is not included in actual Dockerfile but is seperated out into a script file which will have to be manually executed by getting inside the docker only once.

e.g: `bench new-site site1.local --force --db-type postgres --db-root-username postgres --db-root-password <password>`

### Build phase

During the building of the image, the following build args can be passed.

- FRAPPE_PATH - Frappe repo path
- FRAPPE_BRANCH - Frappe Branch name
- FRAPPE_PYTHON - Python version
- FRAPPE - Folder name
- BENCH_BRANCH - Bench repo path
- BENCH_PATH - Branch name

### Run phase

To run frappe successfully and have neat frappe UI to open, we also need to run redis, database(We chose postgres as our database), default-worker, long-worker, short-worker, scheduler, socket-io.

Now each one of these can be run as a seperate docker container or can be run locally or on server in a non-docker way.

As we decided that they too have to be dockerized as individual containers, our docker-compose file reflects the same.

Now according to the address of each of these, `common_site_config.json` of the site has to be updated. In case each of them is dockerized, the `common_site_config.json` in general should looks like below

```{
 "auto_update": false,
 "background_workers": 1,
 "db_host": "<database service name in compose file>",
 "file_watcher_port": 6787,
 "frappe_user": "frappe",
 "gunicorn_workers": 8,
 "rebase_on_pull": false,
 "redis_cache": "redis://<redis service name in compose file>:6379/1",
 "redis_queue": "redis://<redis service name in compose file>:6379/2",
 "redis_socketio": "redis://<redis service name in compose file>:6379/3",
 "restart_supervisor_on_update": false,
 "restart_systemd_on_update": false,
 "serve_default_site": true,
 "shallow_clone": true,
 "socketio_port": 9000,
 "update_bench_on_update": true,
 "webserver_port": 8000
}
```

Here we are just mentioning service names for database and redis, the actual IP address is handled by docker-compose since it internally does the magic, DNS resolution of the service name.
