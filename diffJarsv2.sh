#!/bin/sh

# This script is meant to compare  two JAR files and generate
# a diff (a kind of a changelog). 
#
# Dependencies:
#   - "jar" or "unzip" is required for unpacking *.jar files
#   - "mktemp" is required for creating temporary directories
#   - "diff" is required for comparing *.class file signatures
#
# The following variables are used for the above commands (if they're set):
#   EXTRACT_BIN, MKTEMP_BIN, JAVAP_BIN, DIFF_BIN
# Eg. you can choose a javap location if you've more than one JDK installed.
#
# The behaviour of javap and diff can be modified by setting the JAVAP_OPTS
# and DIFF_OPTS variables.
#
#
# There're a few commands (find, date, which, mkdir, rm, sort, uname) which are
# not listed above, because they're available on most Unix/Linux platforms and
# I believe they're used in a sufficiently cross-platform way.
#
# Tested on:
#   - Ubuntu 20.04 with Java 11
#   - Cent OS 7 with Java 11
#
# Author: DAHER

SUB=" differ "
error=0
#check if file1 and file 2 exists
if [ ! -f "$1" -o ! -f "$2" ]; then
	  echo "usage: $(basename "$0") file1.jar file2.jar [output.diff]"
	    exit 19
fi

umask 077

pwd="$(pwd)"

#GEt full path of file1 , filename is the name only
if echo "$1" | grep "^/" > /dev/null 2>&1; then
	  file1="$1"
  else
	    file1="${pwd}/$1"
fi

filename1="$(basename "$file1")"

#GEt full path of file2,  filename is the name only
if echo "$2" | grep "^/" > /dev/null 2>&1; then
	  file2="$2"
  else
	    file2="${pwd}/$2"
fi
filename2="$(basename "$file2")"

# create an ouptput file if not specified
if [ -n "$3" ]; then
	  output="$3"
  else
#	    output="${pwd}/$(basename "$0" .sh)_$(date "+%Y-%m-%d_%H-%M-%S").diff"
	    output="${pwd}/${filename1}_$(date "+%Y-%m-%d_%H-%M-%S").diff"
fi

# specidy javap option to -public
#[ -z "${JAVAP_OPTS}" ] && JAVAP_OPTS="-public"

#Specify diff option to be -r -U 0 --suppress-common-lines
[ -z "${DIFF_OPTS}" ] && DIFF_OPTS="-r -q -x 'META-INF' "

#Check if mktemp package installed
[ ! -x "${MKTEMP_BIN}" ] && MKTEMP_BIN="$(which mktemp 2> /dev/null)"
if [ ! -x "${MKTEMP_BIN}" ]; then
	  echo "Could not find mktemp."
	    exit 2
fi
#echo "Mktemp: ${MKTEMP_BIN}"

#Use jar if exist if not use unzip for EXTRACT_BIN
if [ ! -x "${EXTRACT_BIN}" ] || ! echo "${EXTRACT_BIN}" | grep -E "^(.*/)?(jar|unzip)\$" > /dev/null 2>&1; then
	  EXTRACT_BIN=$(which jar 2> /dev/null)
	    [ ! -x "${EXTRACT_BIN}" ] && EXTRACT_BIN="$(which unzip 2> /dev/null)"
	      if [ ! -x "${EXTRACT_BIN}" ]; then
		          echo "Could not find neither jar nor unzip."
			      exit 3
			        fi
fi
#Use jar xf 
if echo "${EXTRACT_BIN}" | grep -E "^(.*/)?jar\$" > /dev/null 2>&1; then
	  EXTRACT_OPTS="xf"
  else
	    EXTRACT_OPTS=""
fi
#echo extract option: jar xf or unzip
#if [ -n "${EXTRACT_OPTS}" ]; then
#	  echo "Extract: ${EXTRACT_BIN} ${EXTRACT_OPTS}"
#  else
#	    echo "Extract: ${EXTRACT_BIN}"
#fi
#Check if javap installed and use javap -public option
#[ ! -x "${JAVAP_BIN}" ] && JAVAP_BIN="$(which javap 2> /dev/null)"
#if [ ! -x "${JAVAP_BIN}" ]; then
#	  echo "Could not find javap."
#	    exit 4
#fi
#echo "Javap: ${JAVAP_BIN} ${JAVAP_OPTS}"

#Check if sort is installed
[ ! -x "${JAVAP_POST_PROC_BIN}" ] && JAVAP_POST_PROC_BIN="$(which sort 2> /dev/null)"
if [ ! -x "${JAVAP_POST_PROC_BIN}" ]; then
	  echo "Could not find utility (\"sort\" by default) for post-processing output."
	    exit 5
fi
#echo "Javap post-processor: ${JAVAP_POST_PROC_BIN} ${JAVAP_POST_PROC_OPTS}"

#Check if diif is installed, use -r -U 0 --suppress-common-lines options
[ ! -x "${DIFF_BIN}" ] && DIFF_BIN="$(which diff 2> /dev/null)"
if [ ! -x "${DIFF_BIN}" ]; then
	  echo "Could not find diff."
	    exit 6
fi
#echo "Diff: ${DIFF_BIN} ${DIFF_OPTS}"

#Check if platform is Linux 
uname 2>&1 | grep -i "linux" > /dev/null 2>&1 && [ -z "${LC_ALL}" ] && LC_ALL=C && export LC_ALL

cat << EOH8
****************************************************************************
****************************************************************************

				COMPARING:
 $file1 
 $file2 ...

****************************************************************************
****************************************************************************

EOH8
# Make temp dir to extract first jar
dir1="$("${MKTEMP_BIN}" -d --tmpdir -q "$filename1.XXXX")"
if [ ! -d "${dir1}" ]; then
	  echo "Failed to create temporary directory for $filename1."
	    exit 7
    else
	      echo "Temporary directory for $filename1: ${dir1}"
fi
# Make temp dir to extract second jar
dir2="$("${MKTEMP_BIN}" -d --tmpdir -q "$filename2.XXXX")"
if [ ! -d "${dir2}" ]; then
	  echo "Failed to create temporary directory for $filename2."
	    rm -r "${dir1}"
	      exit 8
      else
	        echo "Temporary directory for $filename2: ${dir2}"
fi

#MAke temp file for file1
dir1list="$("${MKTEMP_BIN}" --tmpdir -q "$filename1.XXXX")"
if [ ! -f "${dir1list}" ]; then
	  echo "Failed to create temporary file for $filename1 content listing."
	    rm -r "${dir1}" "${dir2}"
	      exit 9
fi

#MAke temp file for file2
dir2list="$("${MKTEMP_BIN}" --tmpdir -q "$filename2.XXXX")"
if [ ! -f "${dir2list}" ]; then
	  echo "Failed to create temporary file for $filename2 content listing."
	    rm -r "${dir1}" "${dir2}" "${dir1list}"
	      exit 10
fi

#Extract first jar to dir1 temp folder
echo "Extracting $filename1 into ${dir1} ..."
cd "${dir1}"
"${EXTRACT_BIN}" ${EXTRACT_OPTS} "${file1}" > /dev/null
if [ $? -ne 0 ]; then
	  echo "Failed to extract $filename1."
	    rm -r "${dir1}" "${dir2}" "${dir1list}" "${dir2list}"
	      exit 11
fi

#Extract second jar to dir2 temp folder
echo "Extracting $filename2 into ${dir2} ..."
cd "${dir2}"
"${EXTRACT_BIN}" ${EXTRACT_OPTS} "${file2}" > /dev/null
if [ $? -ne 0 ]; then
	  echo "Failed to extract $filename2."
	    rm -r "${dir1}" "${dir2}" "${dir1list}" "${dir2list}"
	      exit 12
fi

#Remove non .class files from temp folders
#echo "Removing non *.class files from ${dir1} and ${dir2} ..."
#find "${dir1}" "${dir2}" -type f -not -iname "*.class" -print0 | xargs -r -0 rm -f

#Copy sorted files names to temps files for both jar files
cd "${dir1}" && find . -type f -printf "%P\\n" | sort > "${dir1list}"
cd "${dir2}" && find . -type f -printf "%P\\n" | sort > "${dir2list}"

# Write to output
cat << EOH1 > "${output}"
============================================================================

Differences (missing or extra classes) between:
old $filename1 and new $filename2 ...

============================================================================


EOH1

# Diff between two lists of files names
"${DIFF_BIN}" -U 0 -x "META-INF" --suppress-common-lines "${dir1list}" "${dir2list}" >> "${output}"
error=$?
echo diff result for diff jars:$error
#echo "Running ${JAVAP_BIN} on the contents of $filename1 and $filename2 ..."
#Create javap file for each .class of two tempsdirectories


      echo "Generating diff into ${output} ..."
      cd "${pwd}"
#Write the diff to output	  
      cat << EOH2 >> "${output}"

============================================================================
============================================================================

Differences between the common classes of old $filename1 and new $filename2 ...

============================================================================


EOH2
"${DIFF_BIN}" -r  -a -q -x "META-INF"  "${dir1}" "${dir2}" | egrep -v "^Only in " >> "${output}"
DIFFO=$( cat "${output}")
#[[ "$DIFFO" == *"${SUB}"* ]] && error=1 && echo diffooooooooooooooooo
[[ "$DIFFO" == *" differ"* ]] && error=1  && echo diffooooooooooooooooo
echo diff result for common:$error
echo "Cleaning up temporary directories and files ..."
rm -r "${dir1}" "${dir2}" "${dir1list}" "${dir2list}"
#echo $DIFFO
cat << EOH2

============================================================================
============================================================================

EOH2

cat "${output}"
exit $error
