#!/bin/sh
# Tested on:
#   - Ubuntu 20.04 with Java 11
#   - Cent OS 7 with Java 11
#
# Author: DAHER
PATCH=$1
THIRD=$2
OIFS="$IFS"
PWD="$(pwd)"
if [ ! -d $PATCH ]; then
	  echo "Error, could not find PATCH folder."
	    exit 2
fi

if [ ! -d $THIRD ]; then
          echo "Error, could not find 3rd-parties folder."
            exit 2
fi


IFS="
"
#Copy all newly changed jar files(Tnexus jars) to Patch folder
for file in $(find $PATCH -name *.jar -empty -not -path "*/compact/*" -exec basename {} \; | sort | uniq); do
	if [ ! -f $THIRD/$file ]; then
          echo "Error, could not find $file in 3rd parties folder."
          exit 2
	fi
	echo "--------------------------- Patch: Copy $file from 3rd-parties folder---------------------"
	find $PATCH -name $file  -exec cp $THIRD/$file {} \;
	echo "                                       Done!"
      done
      IFS="$OIFS"
#nbrJar=$(find PATCH -type f -iname tnex*.jar -not -path "*/compact/*" | wc -l)
#nbrEmpJar=$(find PATCH -type f -iname tnex*.jar -empty -not -path "*/compact/*" | wc -l)
#nbrNotEmpJar=$(find PATCH -type f -iname tnex*.jar  -not -empty -not -path "*/compact/*" | wc -l)
#echo "The nbr of Emtpy tnexus Jars is: $nbrEmpJar"
#echo "The nbr of all tnexus Jars is: $nbrJar"
echo "The completed 3rd-parties jars  that will be part of the patch are: "
find $PATCH -name *.jar -not -empty -not -path "*/compact/*" -exec basename {} \; | grep -v -i tnexus | sort | uniq
#echo "The nbr of changed  tnexus Jars is: $nbrNotEmpJar"
