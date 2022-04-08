#!/bin/sh
# Tested on:
#   - Ubuntu 20.04 with Java 11
#   - Cent OS 7 with Java 11
#
# Author: DAHER
# This script will test if old version input is less than new version input 
old=$1
new=$2
error=0
[[ "${old}">"${new}" ]] && echo "Error in versions choice: OLD > NEW !!" && error=1
[ $old == $new ] && echo "Error in versions choice: OLD and NEW values are the same !!" && error=1
exit $error
