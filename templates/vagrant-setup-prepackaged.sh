#!/usr/bin/env bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set +x

sudo /opt/sm/bin/sm ext update bosh-solo
