#!/bin/bash
SERVICES=('helios worker' 'helios beat')

for service in "${SERVICES[@]}"; do
    if pgrep -f "$service" > /dev/null; then
        echo "$service service running, everything is fine"
    else
        echo "$service is not running"
        cd /var/www/helios-server || exit 1
        source /var/www/helios-server/venv/bin/activate
        if [[ "$service" == "helios worker" ]]; then
            /var/www/helios-server/venv/bin/celery -A helios worker -l info --concurrency=5 -f celery.log 2>&1 &
        else
            /var/www/helios-server/venv/bin/celery celery -A helios beat --loglevel=INFO 2>&1 &
        fi
        echo "$service is not running! Check $service.log for details."
    fi
done
exit 0