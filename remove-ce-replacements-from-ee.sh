#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )

# get array of keys from "replace" key of composer.json
REPLACE_KEYS_FROM_M2CE=$(curl -s https://raw.githubusercontent.com/magento/magento2/develop/composer.json | jq -c '.replace | keys')

# remove those keys from EE composer.json
cat "${SCRIPTS_DIR}/../../magento/magento2ee/composer.json" | jq --indent 4 "del(.replace$REPLACE_KEYS_FROM_M2CE) | del(.autoload)" | tee "${SCRIPTS_DIR}/../../magento/magento2ee/composer.json"
