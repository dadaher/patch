#!/bin/sh
#author:DAHER
#grep -l " differ " *.diff | while read -r filename; do cp $filename PATCH/Reports; done
mkdir -p Reports
cat << EOH2 > Reports/Jars-diff-report.txt

============================================================================
============================================================================
=                                                                          =
=                    PATCH: Jars diff report                               =
=                                                                          =
============================================================================


EOH2
echo "The completed 3rd-parties jars that will be part of the patch are: "   >> Reports/Jars-diff-report.txt
echo "============================================================================"  >> Reports/Jars-diff-report.txt
find PATCH -name *.jar -not -empty -not -path "*/compact/*" -exec basename {} \; | grep -v -i tnexus | sort | uniq >> Reports/Jars-diff-report.txt
echo " "   >> Reports/Jars-diff-report.txt
echo "============================================================================"  >> Reports/Jars-diff-report.txt
echo " "   >> Reports/Jars-diff-report.txt
echo "The changed Tnexus jars that are part of the patch are: " >> Reports/Jars-diff-report.txt
echo "============================================================================"  >> Reports/Jars-diff-report.txt
find PATCH -iname tnexus*.jar -not -path "*/compact/*" -exec basename {} \; | sort | uniq >> Reports/Jars-diff-report.txt
echo "****************************************************************************"  >> Reports/Jars-diff-report.txt
echo " "  >> Reports/Jars-diff-report.txt
echo 'Copy the below diff files into Jars-diff-report.diff: '
find . -type f  -name "*.diff" -not -path "*/Reports/*" -exec grep -lr  " differ"  {}  \; -exec cp {} Reports/ \;
cat Reports/*.diff >>Reports/Jars-diff-report.txt
find Reports -type f  \( -iname "*.diff" ! -iname "Jars-diff-report.diff" \) -exec rm -r {} \;
mv Reports/Jars-diff-report.txt Reports/Jars-diff-report.diff
