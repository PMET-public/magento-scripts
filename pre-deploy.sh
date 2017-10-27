#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

INITIALIZED_FLAG_FILE=/app/init/app/etc/.initialized

if [ ! -f "${INITIALIZED_FLAG_FILE}" ]; then

  /app/bin/magento module:enable --all
  /app/bin/magento module:disable MagentoEse_PostInstall

  mysql -C --host=database.internal -NBe "DROP DATABASE IF EXISTS \`main\`; CREATE DATABASE IF NOT EXISTS \`main\` DEFAULT CHARACTER SET utf8;"

fi
