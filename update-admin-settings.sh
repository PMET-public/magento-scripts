#!/usr/bin/env bash

# stop on errors
#set -e
# turn on debugging
#set -x

projs=$(magento-cloud projects --pipe)
for p in $projs; do
  envs=$(magento-cloud environments -p $p --no-inactive --pipe)
  for e in $envs; do
    url=$(magento-cloud environment:url -p $p -e $e --pipe | head -1)
    echo Site: $url
    added_random_str=$(echo $url | sed "s/https*:\/\/$e-*\([^-]*\)-$p.*/\1/;")
    # not all envs have this added random string
    [[ $added_random_str = "" ]] && host=$p-$e || host=$p-$e-$added_random_str
    echo Connecting to ssh $host@ssh.us.magentosite.cloud
    ssh $host@ssh.us.magentosite.cloud "mysql -h database.internal -u user -D main -e \"update core_config_data set value = 0 where path in ('dev/js/merge_files','dev/js/minify_files','dev/css/merge_files','dev/css/minify_files','dev/template/minify_html','dev/js/enable_js_bundling','dev/static/sign');\""
    ssh $host@ssh.us.magentosite.cloud "php bin/magento cache:flush"
  done
done
