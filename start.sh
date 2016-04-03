#!/bin/bash

set -euo pipefail

# Display PHP error's or not
if [[ "$ERRORS" == "1" ]] ; then
  sed -i -e "s/error_reporting =.*=/error_reporting = E_ALL/g" /etc/php5/fpm/php.ini
  sed -i -e "s/display_errors =.*/display_errors = On/g" /etc/php5/fpm/php.ini
else
  sed -i -e "s/error_reporting =.*=/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/g" /etc/php5/fpm/php.ini
  sed -i -e "s/display_errors =.*/display_errors = Off/g" /etc/php5/fpm/php.ini
fi

# Tweak nginx to match the workers to cpu's

procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Again set the right permissions (needed when mounting from a volume)
chown -Rf www-data.www-data /usr/share/nginx/html/

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
