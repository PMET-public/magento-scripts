#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

INITIALIZED_FLAG_FILE=/app/init/app/etc/.initialized

if [ ! -f "${INITIALIZED_FLAG_FILE}" ]; then

  /app/bin/magento module:enable MagentoEse_PostInstall
  /app/bin/magento setup:upgrade --keep-generated -n 

  touch "${INITIALIZED_FLAG_FILE}"
fi
