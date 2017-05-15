#!/usr/bin/env bash

# turn on debugging
set -x

assets_url=$(echo $MAGENTO_CLOUD_VARIABLES | base64 --decode | python -c "import sys, json; print(json.load(sys.stdin)['ASSETS_URL'])")
ASSETS_URL_CONFIG=./var/.assets_url


if [ ! -f ${ASSETS_URL_CONFIG} ] || [ "$(cat ${ASSETS_URL_CONFIG})" != "${assets_url}" ]; then
  curl -L "${assets_url}" | tar --strip-components=1 -zx -C .
  echo -n "${assets_url}" > "${ASSETS_URL_CONFIG}"
fi

exit 0
