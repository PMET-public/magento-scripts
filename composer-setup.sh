#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# enable error reporting
mv ./pub/errors/local.xml.sample ./pub/errors/local.xml || :
