#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

url="${1}"
NUM_WORKERS_PER_STORE=1

if [ -z "${url}" ]; then
  cat <<EOF
Usage: $0 [ localhost | <site root url> ]
  ex: https://dv-vm.the1umastory.com
EOF
  exit 1
fi

if [ "${url}" == "localhost" ]; then
  host=$(/usr/bin/mysql -C --host="${DB_SERVER}" --user="${DB_USER}" --password="${DB_PASS}" --database="${DB_NAME}" \
    -NBe "select value from core_config_data where path = 'web/unsecure/base_url'" | \
    sed 's/https*:\/\///;s/\/.*//')
  echo "127.0.0.1 $host" >> /etc/hosts
  url="http://${host}/"
fi

stores="luma_us venia_us luma_de"
# if sample data media dir exists, it's a ref store
if [ -d /magento/vendor/magento/sample-data-media ]; then
  stores="luma_us"
fi

for store in $stores; do
  
  dir=/tmp/$(date '+%Y-%m-%d-%H%M')-$(echo "$url" | sed 's!.*//!!;s!/.*!!')-$store
  mkdir -p $dir && cd $dir

  for i in $(seq 1 $NUM_WORKERS_PER_STORE); do
    wget --recursive \
      --level inf \
      --continue \
      -a logfile \
      -e robots=off \
      --reject jpg,svg,ico,css,js,png,gif,eot,ttf,woff,woff2,mpg,mp4 \
      --reject-regex '[?%]' \
      --no-cookies \
      --no-check-certificate \
      --header "Cookie: store=${STORE}" \
      -N \
      "${url}" &
  done

done