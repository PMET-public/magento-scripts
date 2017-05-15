#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

function delVendorGitDirs {
  find vendor -path '*/.git/*' -delete
}

function rsyncM2CE {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2ce/ ./"
}

function rsyncM2EE {
  rsyncM2CE
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2ee/ ./"
}

function rsyncM2EESampleData {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data/ ./"
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2-sample-data-ee/ ./"
}

function rsyncM2B2B {
  rsyncM2EE
  /bin/bash -c "rsync $rsyncOpts ./vendor/magento/magento2b2b/ ./"
}

function rsyncM2B2BSampleData {
  /bin/bash -c "rsync $rsyncOpts ./vendor/magentoese/module-b2b-media-sample-data/ ./pub/media/"
}

function createMediaDirs {
  mkdir -p ./pub/media/catalog/product ./pub/media/downloadable/spec_sheets ./pub/media/wysiwyg/home
}

function fetchCatalogMedia {
  store_type=$1
  curl -vL "https://github.com/PMET-public/${store_type}-pub-media-catalog-product-cache/tarball/master" |
    tar --strip-components=1 -zx -C ./pub/media/catalog/product/cache
}

rsyncOpts="-rlptz --exclude '/composer.*' --exclude '/.git*' --exclude '/README.md' --exclude '/LICENSE*'"
isPlatform=$(test -e /etc/platform/boot && echo "true" || echo "")
[ $isPlatform ] && rsyncOpts="$rsyncOpts --remove-source-files"
[ $isPlatform ] && delVendorGitDirs

# enable error reporting
mv ./pub/errors/local.xml.sample ./pub/errors/local.xml || :

case $1 in
  ce)
    rsyncM2CE
  ;;
  ref|demo)
    rsyncM2EE; rsyncM2EESampleData
    fetchCatalogMedia $1
  ;;
  b2b)
    rsyncM2B2B; createMediaDirs; rsyncM2B2BSampleData
  ;;
esac
