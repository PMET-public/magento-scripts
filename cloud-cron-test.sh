#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
# set -x


# xpwgonshm6qm2 rnw4cirxgmzx4 5c3fsutojnf5q 2m6nruvxa44h6 jyvegogwpv3su

# echo $(date "+%Y-%m-%d %H:%M:%S") - local >> $0.log
for i in xpwgonshm6qm2 rnw4cirxgmzx4 5c3fsutojnf5q 2m6nruvxa44h6 jyvegogwpv3su; do
  (magento-cloud ssh -p $i -e master 'output=$(
    date "+%Y-%m-%d %H:%M:%S"
    time (php bin/magento cache:flush > /dev/null && curl -Ls localhost/women.html > /dev/null) 2>&1
    nproc
    cat /proc/loadavg | cut -d " " -f 1-3
    hostname
  ); echo $output' >> $0.log) &
done

wait
