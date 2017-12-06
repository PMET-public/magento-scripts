#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )
. "${SCRIPTS_DIR}/lib.sh"

if [ ! -f "${INITIALIZED_FLAG_FILE}" ]; then

  /app/bin/magento indexer:reindex

  if [ "${is_ref}" != "true" ]; then
    /app/bin/magento module:enable MagentoEse_PostInstall
    /app/bin/magento setup:upgrade --keep-generated -n
  fi

  touch "${INITIALIZED_FLAG_FILE}"
fi

