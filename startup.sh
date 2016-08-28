#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# export vars
set -a

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )

if [ ! -f /magento/.initialized ]; then


  "${SCRIPTS_DIR}/initialize-before-db-conn.sh"

#  if [ ! -f /magento/.patched ]; then
#     cd /magento
#     php "${SCRIPTS_DIR}/../../magento/magento-cloud-configuration/patch.php"
#     : > /magento/.patched
#     cd -
#  fi

  "${SCRIPTS_DIR}/initialize-after-db-conn.sh"

  : > /magento/.initialized

fi
