#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x
# export vars
set -a

INITIALIZED_FLAG_FILE=/app/init/app/etc/.initialized

is_ref=$(grep -q '"magento/module-catalog-sample-data"' /app/composer.json && ! grep -q '"magentoese/module-demo-admin-configurations"' /app/composer.json && echo "true" || echo "false")
