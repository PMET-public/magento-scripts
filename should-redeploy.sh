#!/usr/bin/env bash

# turn on debugging
set -x

get_env_var () {
 echo "$MAGENTO_CLOUD_VARIABLES" | base64 --decode | python -c "import sys, json; print json.load(sys.stdin)['$1']"
}

if [ ! -f ./var/.MAGENTO_CLOUD_TREE_ID ] || \
  [ "$(cat ./var/.MAGENTO_CLOUD_TREE_ID)" != "${MAGENTO_CLOUD_TREE_ID}" ] || \
  [ "$(cat ./var/.MAGENTO_CLOUD_BRANCH)" != "${MAGENTO_CLOUD_BRANCH}" ] || \
  [ "$(get_env_var REDEPLOY_ENV)" = "true" ] || \
  [ "$(get_env_var REDEPLOY_ENV)" = "1" ]; then
  exit 0
else
  exit 1
fi
