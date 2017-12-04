#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )
. "${SCRIPTS_DIR}/lib.sh"

if [ ! -f "${INITIALIZED_FLAG_FILE}" ]; then

  /app/bin/magento module:enable --all
  /app/bin/magento module:disable MagentoEse_PostInstall

fi
