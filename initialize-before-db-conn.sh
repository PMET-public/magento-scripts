#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

if [ "${MAGE_MODE}" = "developer" ]; then

  if [ ! -h /magento ]; then
    ln -sf "${APP_DIR}" /magento
  fi

else

  # work on the data volume, not in in the container for better performance and stability
  mkdir -p "${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}"
  ln -sf "${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}" /magento

  # copy app files into linked dir on shared volume
  rsync -a "${APP_DIR}/" /magento

fi

/magento/bin/magento maintenance:enable

/magento/bin/magento maintenance:enable

env-subst.sh


# can i remove this?
sed -i '/SetEnv MAGE_MODE developer/ s/.*/# SetEnv MAGE_MODE developer/' /magento/.htaccess
if [ "${MAGE_MODE}" = "developer" ]; then
  sed -i '/SetEnv MAGE_MODE developer/ s/.*/SetEnv MAGE_MODE developer/' /magento/.htaccess
fi
