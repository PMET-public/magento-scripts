#!/usr/bin/env bash

# turn on debugging
set -x

if [ ! -f ./var/.MAGENTO_CLOUD_TREE_ID ] || [ "$(cat ./var/.MAGENTO_CLOUD_TREE_ID)" != "${MAGENTO_CLOUD_TREE_ID}" ]; then
  echo -n "${MAGENTO_CLOUD_TREE_ID}" > "./var/.MAGENTO_CLOUD_TREE_ID"
  echo "New slug recorded: ${MAGENTO_CLOUD_TREE_ID}" >> /tmp/deploy.log
  exit 0
else
  echo "Slug unchanged." >> /tmp/deploy.log
fi
