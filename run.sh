#i/bin/sh

dev(){
    pwd
    while IFS= read -r line; do
        if [ ! "$line" = "frappe" ] && [ ! "$line" = "" ]; then
            echo "Installing app: $line"
            ./env/bin/pip install -e  ./apps/$line
     fi
    done < ./sites/apps.txt
    bench start
}


prod(){
    cd sites && /home/frappe/frappe-bench/env/bin/gunicorn -b 0.0.0.0:8000 --workers 8 --threads 4 -t 120 frappe.app:application --preload
}
"$@"
