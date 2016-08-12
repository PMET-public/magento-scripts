#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# export vars
set -a

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )

if [ ! -f /magento/.initialized ]; then

  # allow time for apache to start so it can be cleanly stopped
  sleep 5
  /usr/bin/sv stop apache2

  if [ ! -f /magento/.patched ]; then
     php "${SCRIPTS_DIR}/../../magento/magento-cloud-configuration/patch.php"
     : > /magento/.patched
  fi

  "${SCRIPTS_DIR}/initialize-before-db-conn.sh"

  "${SCRIPTS_DIR}/wait-for-db-conn.sh"

  "${SCRIPTS_DIR}/initialize-after-db-conn.sh"

  /usr/bin/sv start apache2

  : > /magento/.initialized

fi
