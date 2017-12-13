#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x
# export vars
set -a

is_ref() {
  grep -q '"magento/module-catalog-sample-data"' "${SCRIPTS_DIR}/../../../composer.json" && ! grep -q '"magentoese/module-demo-admin-configurations"' "${SCRIPTS_DIR}/../../../composer.json"
  return $?
}

is_platform_env() {
  test -f /etc/platform/boot
  return $?
}

is_first_run() {
  test ! -f "${INITIALIZED_FLAG_FILE}"
  return $?
}

first_run_pre_deploy() {
  if ! is_ref; then
    /app/bin/magento module:enable --all
    /app/bin/magento module:disable MagentoEse_PostInstall
  fi
}

first_run_post_deploy() {
  if is_first_run; then
    /app/bin/magento indexer:reindex
    if ! is_ref; then
      /app/bin/magento module:enable MagentoEse_PostInstall
      /app/bin/magento setup:upgrade --keep-generated -n
    fi
    touch "${INITIALIZED_FLAG_FILE}"
  fi
}

record_slug() {
  echo -n "${MAGENTO_CLOUD_TREE_ID}" > "${SLUG_FILE}"
  log_deploy_message "New slug recorded: ${MAGENTO_CLOUD_TREE_ID}"
}

record_branch() {
  echo -n "${MAGENTO_CLOUD_BRANCH}" > "${BRANCH_FILE}"
  log_deploy_message "New branch recorded: ${MAGENTO_CLOUD_BRANCH}"
}

log_deploy_message() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "${DEPLOY_LOG_FILE}"
}

is_new_branch() {
  if [ ! -f ${BRANCH_FILE} ] || [ "$(cat ${BRANCH_FILE})" != "${MAGENTO_CLOUD_BRANCH}" ]; then
    log_deploy_message "Branch changed: ${MAGENTO_CLOUD_BRANCH}"
    return 0
  else
    log_deploy_message "Branch unchanged"
    return -1
  fi
}

is_new_slug() {
  if [ ! -f ${SLUG_FILE} ] || [ "$(cat ${SLUG_FILE})" != "${MAGENTO_CLOUD_TREE_ID}" ]; then
    log_deploy_message "Slug changed: ${MAGENTO_CLOUD_TREE_ID}"
    return 0
  else
    log_deploy_message "Slug unchanged"
    return -1
  fi
}

INITIALIZED_FLAG_FILE=/app/init/app/etc/.initialized
DEPLOY_LOG_FILE=/tmp/deploy.log
SLUG_FILE=/app/var/.MAGENTO_CLOUD_TREE_ID
BRANCH_FILE=/app/var/.MAGENTO_CLOUD_BRANCH
COMPOSER_RSYNC_OPTS="-rlptz --exclude '/composer.*' --exclude '/.git*' --exclude '/README.md' --exclude '/LICENSE*'"
if is_platform_env; then
  COMPOSER_RSYNC_OPTS="$RSYNC_OPTS --remove-source-files"
fi
