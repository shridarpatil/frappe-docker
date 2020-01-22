# frappe-docker
Dockerizing frappe for production


## Build
Docker compose buld by default pull frappe master branch </br>
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
Create new-site
```
bench new-site site1.local --force --db-type postgres --db-root-username postgres --db-root-password root
```
