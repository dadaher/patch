#!/bin/sh
#author:dd
#This script will generte the list of files(jars) that should be removed 
old=$1
new=$2
diff -r -q --suppress-common-lines -x "META-INF" $old $new | grep -v $new | cut -d'/' -f3- | sed 's/lib: /lib\//g' > deleted.txt
sort deleted.txt > deleted-files-report.txt
rm deleted.txt

