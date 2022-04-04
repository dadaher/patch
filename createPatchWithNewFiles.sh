#!/bin/sh
# Tested on:
#   - Ubuntu 20.04 with Java 11
#   - Cent OS 7 with Java 11
#
# Author: DAHER
old=$1
new=$2
OIFS="$IFS"
IFS="
"
rm -rf PATCH
#for file in $(diff -r -U 0 --suppress-common-lines -x"META-INF" $old/delivery $new/delivery | grep -v $old | grep "Only in" | sed 's/lib: /lib\//g' | sed 's/Only in //g'); do
for file in $(diff -r -U 0 --suppress-common-lines -x"META-INF" $old/delivery $new/delivery | grep -v $old | grep "Only in" | sed 's/: /\//g' | sed 's/Only in //g'); do

	dirname="$(dirname "${file}")"
        Patch="PATCH/${dirname}"	  
        echo creating PATCH folders $Patch
	mkdir -p $Patch
	cp ${file} $Patch
      done
      IFS="$OIFS"
