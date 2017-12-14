#!/usr/bin/env bash

# turn on debugging
set -x

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )
. "${SCRIPTS_DIR}/lib.sh"

case $1 in
  ce)
  ;;
  ref)
    /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data/ ./"
    /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data-ee/ ./"
  ;;
  demo)
    /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data/ ./"
    /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data-ee/ ./"
    /bin/bash -c "rsync $COMPOSER_RSYNC_OPTS ./vendor/magentoese/module-venia-media-sample-data/ ./pub/media/"
  ;;
  b2b)
    mkdir -p ./pub/media/catalog/product ./pub/media/downloadable/spec_sheets ./pub/media/wysiwyg/home
    /bin/bash -c "rsync $COMPOSER_RSYNC_OPTS ./vendor/magentoese/module-b2b-media-sample-data/ ./pub/media/"
  ;;
esac

# remove files not needed for deployment on platform
if is_platform_env; then
  find vendor -type d \( -path "*/dev" -o -path "*/Test" -o -path "*/.git" \) -exec rm -rf {} \; || :
  rm -rf vendor/magento/sample-data-media vendor/magento/sample-data-media-ee || :
fi

# enable error reporting
mv ./pub/errors/local.xml.sample ./pub/errors/local.xml || :
