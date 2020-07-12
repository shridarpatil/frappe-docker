#!/bin/sh

install(){
    while IFS= read -r line; do
        if [ ! "$line" = "frappe" ] && [ ! "$line" = "" ]; then
            echo "Installing app: $line"
            if [ -d "./apps/${line}" ]; then
                ./env/bin/pip install -e  ./apps/$line
            fi
     fi
    done < ./sites/apps.txt

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
    install
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
    install;
    if [ "$assets" == true]; then
        bench build;
    fi
    cd /home/frappe/frappe-bench/sites/assets;
    for link in $(find . -type l);
    do
        loc="$(dirname "$link")";
        dir="$(readlink "$link")";
        rm "$link";
        cp -RLv "$dir" "$link";
        rm -rf public
    done
}


main(){
    if [ "$mode" = "prod" ]; then
        prod
    else
       dev
    fi
}


main "$@"
