#! /bin/sh
set -e

sh bootstrap.sh
sh build_lib.sh
sh run_test.sh
