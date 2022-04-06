#!/bin/sh
old=$1
new=$2
OIFS="$IFS"
IFS="
"
#Copy all newly changed non-jar files to Patch folder
for file in $( diff -r -q -x"META-INF" $old/delivery $new/delivery |grep -v 'Only in '|  cut -d' ' -f4 | grep $new |grep -v ".jar"); do
#	 file1="$(echo $file | cut -d ' ' -f1 )"
#	 file2="$(echo $file | cut -d ' ' -f2 )" 
	 dirname="$(dirname "${file}")"
          Patch="PATCH/${dirname}"	  
#          mkdir -p $Patch
#	  cp "${file}" 
        echo creating-updating PATCH folders with ${file}
	mkdir -p $Patch
	cp ${file} $Patch
      done
      IFS="$OIFS"
