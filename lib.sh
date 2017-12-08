#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x
# export vars
set -a

INITIALIZED_FLAG_FILE=/app/init/app/etc/.initialized

IS_REF=$(grep -q '"magento/module-catalog-sample-data"' /app/composer.json && ! grep -q '"magentoese/module-demo-admin-configurations"' /app/composer.json && echo "true" || echo "false")

IS_PLATFORM_ENV=$(test -e /etc/platform/boot && echo "true" || echo "false")
RSYNC_OPTS="-rlptz --exclude '/composer.*' --exclude '/.git*' --exclude '/README.md' --exclude '/LICENSE*'"
[ "${IS_PLATFORM_ENV}" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --remove-source-files"
