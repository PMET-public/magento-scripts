#!/usr/bin/env bash

# turn on debugging
set -x
MAGENTO_CLOUD_TREE_ID_FILE=./var/.MAGENTO_CLOUD_TREE_ID


if [ ! -f ${MAGENTO_CLOUD_TREE_ID_FILE} ] || [ "$(cat ${MAGENTO_CLOUD_TREE_ID_FILE})" != "${MAGENTO_CLOUD_TREE_ID}" ]; then
  echo -n "${MAGENTO_CLOUD_TREE_ID}" > "${MAGENTO_CLOUD_TREE_ID_FILE}"
  echo "New slug recorded: ${MAGENTO_CLOUD_TREE_ID}" >> /tmp/deploy.log
  exit 0
fi

# with a non-zero exit status, the rest of the cmds should not continue
echo "Skipping rest of deploy ..." >> /tmp/deploy.log
exit 1
