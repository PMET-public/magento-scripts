#!/usr/bin/env bash

# stop on errors
# set -e
# turn on debugging
# set -x

# automate this test w/ a crontab entry like:
# */5 * * * * sleep 30 & $0
# 2,7,12,17,22,27,32,37,42,47,52,57 * * * * sleep 30 & $0

# each of these projects is on a different host
# xpwgonshm6qm2 rnw4cirxgmzx4 5c3fsutojnf5q 2m6nruvxa44h6 jyvegogwpv3su

# run on these projects on different hosts (skipping 1 that seems to fail too often)
for i in xpwgonshm6qm2 rnw4cirxgmzx4 5c3fsutojnf5q 2m6nruvxa44h6; do
  # run several cmds but collect the output into 1 line
  # also run the cmds in parallel
  (magento-cloud ssh -p $i -e master 'output=$(
    date "+%Y-%m-%d %H:%M:%S"
    time (php bin/magento cache:flush > /dev/null && curl -Ls localhost/women.html > /dev/null) 2>&1
    nproc
    cat /proc/loadavg | cut -d " " -f 1-3
    hostname
  ); echo $output' >> dirname "$(readlink -f "$0")"/$0.log) &
done
