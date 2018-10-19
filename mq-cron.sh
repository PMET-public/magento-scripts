#!/usr/bin/env bash

set -x

. "$( cd $(dirname $0) ; pwd -P )/lib.sh"
cd "${APP_ROOT}"

# magento should use rabbit mq but instead implemented their own message queue in mysql?!
# magento should use a proper process manager but currently recommends cron and grepping for running processes?!
# http://devdocs.magento.com/guides/v2.2/release-notes/release-candidate/install.html
for queue in sharedCatalogUpdatePrice sharedCatalogUpdateCategoryPermissions; do
  ps ax | grep -q "[ ]${queue}" || nohup php bin/magento queue:consumers:start "${queue}" >/dev/null 2>&1 &
done

