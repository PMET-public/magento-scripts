#!/usr/bin/env bash

# turn on debugging
set -x

if [ ! -f ./var/.MAGENTO_CLOUD_TREE_ID ] || \
  [ "$(cat ./var/.MAGENTO_CLOUD_TREE_ID)" != "${MAGENTO_CLOUD_TREE_ID}" ] || \
  [ "${REDEPLOY_ENV}" = "true" ] || \
  [ "${REDEPLOY_ENV}" = "1" ]; then
  exit 0
else
  exit 1
fi
