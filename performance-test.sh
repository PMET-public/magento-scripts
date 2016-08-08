#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# simple performance test using curl to measure server response

usage() {
  echo "Usage: ${0##*/} [ url-ending-with-slash ]"
  exit 1
}

if [ "$#" -gt 2 ]; then
  usage
fi

if [ "$#" -eq 1 ]; then
  if !(echo $1 | egrep -q "\/$") ; then
    usage
  fi
fi 

BASE_URL=${1:-"http://localhost/"}
URLS="gear.html customer/account/create/ catalogsearch/result/?q=watch"
CMD=/magento/bin/magento

fetch_url () {
  curl -o /dev/null -k -w "%{time_connect},%{time_starttransfer},%{time_total}," $1
}

cd /magento
sudo -u "${WEB_SERVER_USER}" "${CMD}" cache:enable
sudo -u "${WEB_SERVER_USER}" "${CMD}" cache:flush

# output header row
echo -ne "date,url," > ~/results.txt
for j in {1..2}; do
  for i in {1..3}; do
    prefix=$([ "$j" == 1 ] && echo "" || echo "cached_")
    echo -ne "${prefix}time_connect,${prefix}time_starttransfer,${prefix}time_total," >> ~/results.txt
  done
done
echo "" >> ~/results.txt


for url in $URLS; do
  echo -ne "$(date),$url," >> ~/results.txt
  result=""
  for i in {1..10}; do
    if [ "$i" -lt 6 ]; then
      sudo -u "${WEB_SERVER_USER}" "${CMD}" cache:flush
    fi
    result="$result$(fetch_url $BASE_URL$url)"
  done
  echo -e "$result" >> ~/results.txt
done
