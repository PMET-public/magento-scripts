#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

SCRIPTS_DIR=$( cd $(dirname $0) ; pwd -P )
. "${SCRIPTS_DIR}/lib.sh"

if is_first_run; then
  first_run_pre_deploy
fi

if is_new_slug; then
  php ./vendor/bin/m2-ece-deploy
elif is_new_branch; then
  php ./vendor/bin/m2-ece-branch
fi

if is_new_slug; then
  record_slug
fi

if is_new_branch; then
  record_branch
fi

if is_first_run; then
  first_run_post_deploy
fi

# remove dir not needed after deploy
rm -rf init/pub/media/*


