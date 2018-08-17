#!/usr/bin/env bash

# turn on debugging
set -x

cur_dir=$( cd $(dirname $0) ; pwd -P )
. $cur_dir/lib.sh

case $1 in
  ce)
  ;;
  ref)
    rsyncSampleMedia
  ;;
  demo)
    rsyncSampleMedia
    /bin/bash -c "rsync $COMPOSER_RSYNC_OPTS vendor/magentoese/module-venia-media-sample-data/ pub/media/ || :"
  ;;
  b2b)
    mkdir -p ./pub/media/catalog/product ./pub/media/downloadable/spec_sheets ./pub/media/wysiwyg/home
    /bin/bash -c "rsync $COMPOSER_RSYNC_OPTS vendor/magentoese/module-b2b-media-sample-data/ pub/media/ || :"
  ;;
esac

# remove files not needed for deployment on platform
if is_platform_env; then
  find vendor -type d \( -path "*/.git" \) -exec rm -rf {} \; 2>/dev/null || :
  rm -rf vendor/magento/sample-data-media || :
fi
