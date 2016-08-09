#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

if [ "${ENV_MODE}" = "developer" ]; then

  # create special user to map to host (vagrant) user to the docker useradd
  VAGRANT_UID=$(stat -c "%u" "${APP_DIR}")
  VAGRANT_GID=$(stat -c "%g" "${APP_DIR}")
  groupadd -g "${VAGRANT_GID}" "${WEB_SERVER_USER}" || :
  adduser --gid "${VAGRANT_GID}" --uid "${VAGRANT_UID}" --disabled-password --gecos "" "${WEB_SERVER_USER}" || :

  WEB_SERVER_GROUP=$(getent group "${VAGRANT_GID}" | cut -d: -f1);

  ln -sf "${APP_DIR}" /magento

else

  # work on the data volume, not in in the container for better performance and stability
  mkdir -p "${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}"
  ln -sf "${SHARED_TMP_PATH}/${MAGENTO_HOSTNAME}" /magento

  # copy app files into linked dir on shared volume
  rsync -a "${APP_DIR}/" /magento

fi

# randomize start of php cron job and run once per hour
sed -i "s/^[0-9,]\+/$(echo $((RANDOM%60)))/;" /etc/cron.d/php

env-subst.sh

ln -sf /etc/php/7.0/additional/apache2.ini /etc/php/7.0/apache2/conf.d/
ln -sf /etc/php/7.0/additional/cli.ini /etc/php/7.0/cli/conf.d/
for i in opcache xdebug; do
  ln -sf /etc/php/7.0/additional/${i}.ini /etc/php/7.0/apache2/conf.d/
  ln -sf /etc/php/7.0/additional/${i}.ini /etc/php/7.0/cli/conf.d/
done

# show errors on pages
cp /magento/pub/errors/local.xml.sample /magento/pub/errors/local.xml

# include b2b if it exists
if [ -d "${APP_DIR}/vendor/magento/magento2b2b/app" ]; then
  cp -R "${APP_DIR}/vendor/magento/magento2b2b/app" "${APP_DIR}"
fi

sed -i '/SetEnv MAGE_MODE developer/ s/.*/# SetEnv MAGE_MODE developer/' /magento/.htaccess
if [ "${ENV_MODE}" = "developer" ]; then
  sed -i '/SetEnv MAGE_MODE developer/ s/.*/SetEnv MAGE_MODE developer/' /magento/.htaccess
fi

# until https://github.com/magento/magento2/issues/2461 is merged
sed -i 's/this->max_execution_time = .*;/this->max_execution_time = 600;/' /magento/vendor/tubalmartin/cssmin/cssmin.php
