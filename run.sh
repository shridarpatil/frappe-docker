#!/bin/sh

install(){
    cat "./sites/apps.txt" | { cat ; echo ; } | while read line; do echo $line;
    if [ ! "$line" = "frappe" ] && [ ! "$line" = "" ]; then
            echo "Installing app: $line"
            if [ -d "./apps/${line}" ]; then
                ./env/bin/pip install -e  ./apps/$line
            fi
        fi
    done
}

# Fix DB permissions to allow connections from any container (workers, etc.)
fix_db_permissions(){
    for site_dir in ./sites/*/; do
        site=$(basename "$site_dir")
        config_file="./sites/${site}/site_config.json"

        # Skip non-site directories
        if [ ! -f "$config_file" ]; then
            continue
        fi

        db_type=$(grep -o '"db_type": "[^"]*' "$config_file" | cut -d'"' -f4)
        db_name=$(grep -o '"db_name": "[^"]*' "$config_file" | cut -d'"' -f4)
        db_user=$(grep -o '"db_user": "[^"]*' "$config_file" | cut -d'"' -f4)
        db_pass=$(grep -o '"db_password": "[^"]*' "$config_file" | cut -d'"' -f4)

        if [ -n "$db_name" ] && [ -n "$db_user" ]; then
            echo "Fixing DB permissions for site: $site (${db_type:-mariadb})"
            if [ "$db_type" = "postgres" ]; then
                PGPASSWORD=root psql -h postgres -U postgres -c \
                    "ALTER USER \"${db_user}\" WITH PASSWORD '${db_pass}'; GRANT ALL PRIVILEGES ON DATABASE \"${db_name}\" TO \"${db_user}\";" 2>/dev/null || true
            else
                mysql -h mariadb -uroot -proot -e \
                    "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%' IDENTIFIED BY '${db_pass}'; FLUSH PRIVILEGES;" 2>/dev/null || true
            fi
        fi
    done
}

dev(){
    cat <<"EOF"
     _                                  _
    | |                                | |
  __| | _____   __  _ __ ___   ___   __| | ___
 / _` |/ _ \ \ / / | '_ ` _ \ / _ \ / _` |/ _ \
| (_| |  __/\ V /  | | | | | | (_) | (_| |  __/
 \__,_|\___| \_/   |_| |_| |_|\___/ \__,_|\___|

EOF
    bench setup requirements
    install
    fix_db_permissions
    bench start
}


prod(){
    cat <<"EOF"
                     _                       _
                    | |                     | |
 _ __  _ __ ___   __| |  _ __ ___   ___   __| | ___
| '_ \| '__/ _ \ / _` | | '_ ` _ \ / _ \ / _` |/ _ \
| |_) | | | (_) | (_| | | | | | | | (_) | (_| |  __/
| .__/|_|  \___/ \__,_| |_| |_| |_|\___/ \__,_|\___|
| |
|_|

EOF
    build
    cd /home/frappe/frappe-bench/sites && /home/frappe/frappe-bench/env/bin/gunicorn -b 0.0.0.0:8000 --workers 8 --threads 4 -t 120 frappe.app:application --preload

}


build(){
    install
    fix_db_permissions
    if [ "$assets" = true ]; then
        echo "Building assets....."
        bench build --hard-link;
    fi
}


main(){
    if [ "$mode" = "prod" ]; then
        prod
    else
       dev
    fi
}

# Only run main if script is executed directly, not sourced
if [ "${0##*/}" = "run.sh" ] || [ "$1" = "run" ]; then
    main "$@"
fi
