#!/bin/sh

build(){
#    cd workplace
    # frappe repo path
    echo "[i] Frappe repo: $FRAPPE_PATH"
    echo "[i] Frappe branch: $FRAPPE_BRANCH"
    if [ "$FRAPPE_PATH" = "" ]; then
        FRAPPE_PATH="https://github.com/frappe/frappe.git"
    fi

    # frappe branch
    if [ "$FRAPPE_BRANCH" = "" ]; then
        FRAPPE_BRANCH="master"
    fi

    # Python Version
    if [ "$FRAPPE_PYTHON" = "" ]; then
        FRAPPE_PYTHON="python3"
    fi

    echo "[i] Python Version: $FRAPPE_PYTHON"
    if [ "$FRAPPE" = "" ]; then
        FRAPPE="frappe-bench"
    fi
    BENCH="bench-repo"
    echo "====================== Cloning bench ==============================="
    git clone -b $BENCH_BRANCH $BENCH_PATH $BENCH
    pip install --user -e bench-repo && rm -rf ~/.cache/pip
    echo "====================== bench init =================================="
    echo "frappe $FRAPPE frappe-path $FRAPPE_PATH "
    export PATH=$PATH:~/.local/bin/
    bench init $FRAPPE --frappe-path $FRAPPE_PATH --frappe-branch $FRAPPE_BRANCH  --python $FRAPPE_PYTHON --no-backups --no-auto-update --skip-redis-config-generation --skip-assets --no-procfile

}

new_site(){
    if [ "$DB_HOST" = "" ]; then
        DB_HOST="172.17.0.1"
    fi
    if [ "$SITE_NAME" = "" ]; then
        SITE_NAME="site1.local"
    fi
    echo "Set mariadb host " $DB_HOST
    bench set-mariadb-host $DB_HOST
    echo "New site" $DB_NAME
    bench new-site $SITE_NAME --db-name $DB_NAME --mariadb-root-password $MYSQL_ROOT_PWD
    bench use $SITE_NAME
}
"$@"
