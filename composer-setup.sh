#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

function delVendorGitDirs {
  find vendor -type d -name .git -delete
}

function rsyncM2CE {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2ce/ ./"
}

function rsyncM2EE {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2ee/ ./"
}

function rsyncM2EESampleData {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data/ ./"
}

function rsyncM2B2B {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2b2b/ ./"
}

function rsyncM2B2BMedia {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magentoese/module-b2b-media-sample-data/ ./pub/media/"
}

function createMediaDirs {
  mkdir -p ./pub/media/catalog/product ./pub/media/downloadable/spec_sheets ./pub/media/wysiwyg/home
}

isPlatform=$(test -e /etc/platform/boot || echo "")
rsyncOpts="-rlptz --exclude '/composer.*' --exclude '/.git*' --exclude '/README.md' --exclude '/LICENSE*'"
[ $isPlatform ] && rsyncOpts="$rsyncOpts --remove-source-files"
[ $isPlatform ] && delVendorGitDirs
rsyncM2CE

case $1 in
  ce) ;;
  ref)
    rsyncM2EE; rsyncM2EE; rsyncM2EESampleData
  ;;
  demo)
    rsyncM2EE; rsyncM2EE; rsyncM2EESampleData
  ;;
  b2b)
    rsyncM2EE; rsyncM2EE; rsyncM2EESampleData; createMediaDirs
  ;;
esac
