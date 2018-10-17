#!/usr/bin/env bash

set -x

. "$( cd $(dirname $0) ; pwd -P )/lib.sh"
cd "${APP_ROOT}"

# new check for cron key https://github.com/magento/magento2ce/blob/5c82b225c700436ab0f14ad281b025fb0e75b3ad/app/code/Magento/Cron/Console/Command/CronCommand.php#L93
# how env.php is updated https://github.com/magento/ece-tools/blob/5e9645eea1879efce45b8e899dce15c9d08a8399/src/Process/Deploy/EnableCron.php#L61
# it's confusing b/c cron enabled won't = 1 b/c it won't even exist
if php -r '$a=include "/app/app/etc/env.php";exit(!isset($a["cron"]["enabled"]) || $a["cron"]["enabled"] == 1 ? 0 : 1);'; then

  # normal magento cron
  php bin/magento cron:run &

  # magento should use rabbit mq but instead implemented their own message queue in mysql?!
  # magento should use a proper process manager but currently recommends cron and grepping for running processes?!
  # http://devdocs.magento.com/guides/v2.2/release-notes/release-candidate/install.html
  for queue in sharedCatalogUpdatePrice sharedCatalogUpdateCategoryPermissions; do
    ps ax | grep -q "[ ]${queue}" || nohup php bin/magento queue:consumers:start "${queue}" >/dev/null 2>&1 &
  done

fi
