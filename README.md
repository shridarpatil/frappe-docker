<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>
# frappe-docker
Dockerizing frappe for production

Prerequisites
- ## Install <a href="http://recordit.co/" target="_blank">**Docker**</a>. 

## Clone 
```git@github.com:shridarpatil/frappe-docker.git```
```cd  frappe-docker```

## Pull docker image
```docker pull shridh0r/frappe:\<tagname\>```

## Run
Update the same tag in docker compose file 

```docker-compose up
docker exec -it <app-container-name> /bin/sh

bench reinstall
bench build
```
## Build
Docker compose build by default pull's frappe master branch </br>
``` docker-compose build ```

#### Build args
  - [x] FRAPPE_PATH - Frappe repo path  
  - [x] FRAPPE_BRANCH - Branch name
  - [x] FRAPPE_PYTHON - Python version
  - [x] FRAPPE - Folde name
  - [x] BENCH_BRANCH - Bench repo path
  - [x] BENCH_PATH - Branch name

Set frappe-path/branch dynamically by passing build-arg
```
docker-compose build --build-arg FRAPPE_PATH=https://github.com/zerodhatech/frappe.git --build-arg FRAPPE_BRANCH=zero_v12
```

## Run
```docker-compose up```

## Create site
Exec into docker container and create new site

Create new-site
```
bench new-site site1.local --force --db-type postgres --db-root-username postgres --db-root-password root
```
