#!/usr/bin/env bash

# turn on debugging
set -x

cur_dir=$( cd $(dirname $0) ; pwd -P )
. $cur_dir/lib.sh

# remove files not needed for deployment on platform
if is_platform_env; then
  find vendor -type d \( -path "*/.git" \) -exec rm -rf {} \; 2>/dev/null || :
fi
