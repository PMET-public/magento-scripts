#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# set hostname, static, & media url
/usr/bin/mysql -C --host=db --user="${DB_USER}" --password="${DB_PASS}" --database="${DB_NAME}" \
  -NBe "update core_config_data set value = 'https://${MAGENTO_HOSTNAME}/' where path like '%/base_url'" 
/usr/bin/mysql -C --host=db --user="${DB_USER}" --password="${DB_PASS}" --database="${DB_NAME}" \
  -NBe "update core_config_data set value = 'https://${CDN_SUBDOMAIN}.${DOMAIN}.${TLD}/media-${RELEASE_TAG}/media/' where path like '%/base_media_url'" 
# in m2, if you are in developer mode and use a static url, the assets will not be deployed automatically, so don't set the static urls
if [ "${MAGE_MODE}" != "developer" ]; then
  /usr/bin/mysql -C --host=db --user="${DB_USER}" --password="${DB_PASS}" --database="${DB_NAME}" \
    -NBe "update core_config_data set value = 'https://${CDN_SUBDOMAIN}.${DOMAIN}.${TLD}/static-${RELEASE_TAG}/static/' where path like '%/base_static_url'" 
fi
