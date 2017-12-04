#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

INITIALIZED_FLAG_FILE=/app/init/app/etc/.initialized

is_ref=$(grep -q '"magento/module-catalog-sample-data"' /app/composer.json && ! grep -q '"magentoese/module-demo-admin-configurations"' /app/composer.json && echo "true" || echo "false")


if [ ! -f "${INITIALIZED_FLAG_FILE}" ]; then

  # we for an  initial indexing in demo, but ref does not.
  # so index initially if composer appears to be ref
  if [ $is_ref == "true" ]; then
    /app/bin/magento indexer:reindex
  else
    /app/bin/magento module:enable MagentoEse_PostInstall
    /app/bin/magento setup:upgrade --keep-generated -n
  fi

  touch "${INITIALIZED_FLAG_FILE}"
fi

