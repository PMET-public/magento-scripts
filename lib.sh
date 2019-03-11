#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x
# export vars
set -a

first_run_pre_deploy() {
  if ! is_ref; then
: #  currently fails on platform b/c var/generated is not writeable
#    /app/bin/magento module:enable --all
#    /app/bin/magento module:disable MagentoEse_PostInstall
  fi
}

first_run_post_deploy() {
  if is_first_run; then
    # /app/bin/magento cron:install
    /app/bin/magento indexer:reindex
    if ! is_ref; then
: #  currently fails on platform b/c var/generated is not writeable
#      /app/bin/magento module:enable MagentoEse_PostInstall
#      /app/bin/magento setup:upgrade --keep-generated -n
    fi
    touch "${INITIALIZED_FLAG_FILE}"
  fi
}

is_first_run() {
  test ! -f "${INITIALIZED_FLAG_FILE}"
  return $?
}

is_new_branch() {
  test ! -f ${BRANCH_FILE} -o "$(cat ${BRANCH_FILE})" != "${MAGENTO_CLOUD_BRANCH}"
  return $?
}

is_new_slug() {
  test ! -f ${SLUG_FILE} -o "$(cat ${SLUG_FILE})" != "${MAGENTO_CLOUD_TREE_ID}"
  return $?
}

is_platform_env() {
  test -f /etc/platform/boot
  return $?
}

is_ref() {
  grep -q '"magento/module-catalog-sample-data"' "${APP_ROOT}/composer.json" && ! grep -q '"magentoese/module-demo-admin-configurations"' "${APP_ROOT}/composer.json"
  return $?
}

log_deploy_message() {
  mkdir -p "${APP_ROOT}/app/etc/log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "${DEPLOY_LOG_FILE}"
}

record_slug() {
  echo -n "${MAGENTO_CLOUD_TREE_ID}" > "${SLUG_FILE}"
  log_deploy_message "New slug recorded: ${MAGENTO_CLOUD_TREE_ID}"
}

record_branch() {
  echo -n "${MAGENTO_CLOUD_BRANCH}" > "${BRANCH_FILE}"
  log_deploy_message "New branch recorded: ${MAGENTO_CLOUD_BRANCH}"
}

APP_ROOT=$( cd $(dirname $0)/../../.. ; pwd -P )

INITIALIZED_FLAG_FILE="${APP_ROOT}/app/etc/.initialized"
DEPLOY_LOG_FILE="${APP_ROOT}/app/etc/log/deploy.log"
SLUG_FILE="${APP_ROOT}/app/etc/.MAGENTO_CLOUD_TREE_ID"
BRANCH_FILE="${APP_ROOT}/app/etc/.MAGENTO_CLOUD_BRANCH"
