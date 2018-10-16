#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

. "$( cd $(dirname $0) ; pwd -P )/lib.sh"

if is_first_run; then
  first_run_pre_deploy
fi

php ./vendor/bin/ece-tools deploy

if is_new_slug; then
  record_slug
fi

if is_new_branch; then
  record_branch
fi

if is_first_run; then
  first_run_post_deploy
fi

