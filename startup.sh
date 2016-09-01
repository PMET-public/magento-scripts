#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# export vars
set -a

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )

if [ ! -f /magento/.initialized ]; then

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

/usr/bin/mysql -C --host="${DB_SERVER}" --user="${DB_USER}" --password="${DB_PASS}" \
  -NBe "DROP DATABASE IF EXISTS \`${DB_NAME}\`;
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8;"

# remove old di dir first if it exists
rm -rf /magento/var/di || :
php /magento/bin/magento module:enable --all

if [ -z "${ENCRYPTION_KEY}" ]; then
  ENCRYPTION_KEY=$(cat /dev/urandom | head -1 | sha256sum | head -c 16)
fi

php /magento/bin/magento setup:install \
  --session-save=db \
  --cleanup-database \
  --currency=USD \
  --base-url=https://${MAGENTO_HOSTNAME}/  \
  --base-url-secure=https://${MAGENTO_HOSTNAME}/  \
  --language=en_US \
  --timezone=America/Los_Angeles \
  --db-host="${DB_SERVER}" \
  --db-name="${DB_NAME}" \
  --db-user="${DB_USER}" \
  --db-password="${DB_PASS}" \
  --backend-frontname=admin \
  --admin-user="${ADMIN_USER}" \
  --admin-firstname=first \
  --admin-lastname=last \
  --admin-email=admin@admin.com \
  --admin-password="${ADMIN_PASSWORD}" \
  --key="${ENCRYPTION_KEY}"

$( readlink -f $(dirname $0) )/set-magento-base-urls.sh

php /magento/bin/magento deploy:mode:set "${MAGE_MODE}"

# compilation requires information from app/etc/env.php so must occur after installation
# or at least until app/etc/env.php default block has been written
#if [ "${ENABLE_DI_COMPILE}" = "true" ]; then
#  php /magento/bin/magento setup:di:compile
#fi

php /magento/bin/magento index:reindex
php /magento/bin/magento cache:flush

# clear any old static and preprocessed files first
rm -rf /magento/pub/static/* /magento/var/view_preprocessed || :

# in "developer" mode, static content will automatically be created as needed, so deploy content for other modes
# http://devdocs.magento.com/guides/v2.0/config-guide/cli/config-cli-subcommands-static-view.html
if [ "${MAGE_MODE}" != "developer" ]; then

  SHARED_STATIC_CONTENT="${SHARED_TMP_PATH}/${STORE_MODE}/${RELEASE_TAG}"

  # if this specific static content has already been generated it; reuse it
  if [ -d "${SHARED_STATIC_CONTENT}" ]; then

    cp -rf "${SHARED_STATIC_CONTENT}/static" /magento/pub/
    cp -rf "${SHARED_STATIC_CONTENT}/view_preprocessed" /magento/var/

  else

    # generate the content and copy the resulting files to a shared space
    php /magento/bin/magento setup:static-content:deploy $(echo ${LANG_TO_DEPLOY})
    "${SCRIPTS_DIR}/create-optimized-static-dir.sh"
    mkdir -p "${SHARED_STATIC_CONTENT}"
    cp -rf /magento/pub/static "${SHARED_STATIC_CONTENT}"
    cp -rf /magento/var/view_preprocessed "${SHARED_STATIC_CONTENT}"

  fi

fi

crontab -u www-data /etc/cron.d/magento


#  if [ ! -f /magento/.patched ]; then
#     cd /magento
#     php "${SCRIPTS_DIR}/../../magento/magento-cloud-configuration/patch.php"
#     : > /magento/.patched
#     cd -
#  fi

# reset the ownership of files since composer was run as root
chown -RL www-data /magento

if [ "${ENABLE_XDEBUG}" = true ]; then
  phpenmod xdebug
  phpdismod opcache
fi

# ensure server up and then warm the cache
# must do in the background b/c apache not started yet
if [ "${WARM_CACHE}" = true ]; then
  (sleep 30 && "${SCRIPTS_DIR}/warm-cache.sh" localhost) &
fi

/magento/bin/magento maintenance:disable



fi
