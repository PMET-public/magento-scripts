#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# Wait for MySQL to come up.
until /usr/bin/mysql -C --host="${DB_SERVER}" --user="${DB_USER}" --password="${DB_PASS}" -e ""; do
    echo "Failed to connect to MySQL - retrying..."
    sleep 5
done
