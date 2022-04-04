#!/bin/sh
# Tested on:
#   - Ubuntu 20.04 with Java 11
#   - Cent OS 7 with Java 11
#
# Author: DAHER
old=$1
new=$2
OIFS="$IFS"
PWD="$(pwd)"
IFS="
"
#Copy all empty Tnexus jars to Patch folder
for file in $( find $new -type f -iname Tnexus-* -not -path "*/compact/*"); do
          dirname="$(dirname "${file}")"
          Patch="PATCH/${dirname}"
          echo "----------------------------------> ${file} to  PATCH folders $Patch"
          mkdir -p $Patch
          cp ${file} $Patch
         # find tnexus-DXB-2021-12-15-1-changed -name Tnexus-core.jar -not -path "*/compact/*" -exec cp PATCH/tnexus-DXB-2021-12-15-1/delivery/compact/Tnexus-core.jar {} \;
#find /path/to/dir -type d -empty -print0 -exec rmdir -v "{}" \;
      done
      IFS="$OIFS"


#find tnexus-DXB-2021-12-15-1 -type f -iname Tnexus-* -not -path "*/compact/*"
