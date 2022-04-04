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
#Copy all newly changed jar files(Tnexus jars) to Patch folder
for file in $( diff -r -q -x"META-INF" $old/delivery $new/delivery |grep -v 'Only in ' | grep  ".jar" | cut -d ' ' -f2,4); do
	 file1="$(echo $file | cut -d ' ' -f1 )"
	 file2="$(echo $file | cut -d ' ' -f2 )" 
         #DIFF="$($PWD/diffJarsv2.sh $file1 $file2) | grep ' differ' "
	#Deeply compare the jars using diffJarsv2: return 0 if same ,1 if different
	$PWD/diffJarsv2.sh $file1 $file2	
	differ=$?
        if [ "$differ" -eq "1" ]; then
	  echo "DIFFO..COPY..COPY..DIFFO.."
	  dirname="$(dirname "${file2}")"
          Patch="PATCH/${dirname}"	  
          echo "----------------------------------> Copy new  ${file2} to  PATCH folders $Patch"
          mkdir -p $Patch
	  cp ${file2} $Patch
          basename="$(basename "${file2}")"
	  find PATCH -name $basename -not -path "*/compact/*" -exec cp $Patch/$basename {} \;
	fi
	if [ "$differ" -eq "0" ]; then
	basename="$(basename "${file2}")"	
	echo "--------------------------- Removing $basename from Patch---------------------"
	echo ""
	find PATCH -name $basename -empty -not -path "*/compact/*" -exec rm -f {} \;
	fi
#find /path/to/dir -type f -empty -print0 -exec rm -f "{}" \;
      done
      IFS="$OIFS"
#nbrEmpJar=$(find PATCH -type f -iname tnex*.jar -empty -not -path "*/compact/*" | wc -l)
#nbrJar=$(find PATCH -type f -iname tnex*.jar -not -path "*/compact/*" | wc -l)
#nbrNotEmpJar=$(find PATCH -type f -iname tnex*.jar  -not -empty -not -path "*/compact/*" | wc -l)
#echo "The nbr of Emtpy tnexus Jars is: $nbrEmpJar"
#echo "The nbr of all tnexus Jars is: $nbrJar"
echo "The changed Tnexus jars that will be part of the patch are: "
find PATCH -iname tnexus*.jar -not -path "*/compact/*" -exec basename {} \; | sort | uniq
#echo "The nbr of changed  tnexus Jars is: $nbrNotEmpJar"
