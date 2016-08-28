#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

if [ "${MAGE_MODE}" != "developer" ]; then

  # work on the data volume, not in in the container for better performance and stability
  mkdir -p "${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}"

  # copy app files into linked dir on shared volume
  rsync -a "${APP_DIR}/" "${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}"

  export APP_DIR="${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}"

fi

if [ ! -h /magento ]; then
  ln -sf "${APP_DIR}" /magento
fi

/magento/bin/magento maintenance:enable

env-subst.sh
