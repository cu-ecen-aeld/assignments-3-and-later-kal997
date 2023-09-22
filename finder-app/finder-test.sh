#!/bin/sh
# Tester script for assignment 1 and assignment 2
# Author: Siddhant Jajoo

set -e
set -u

NUMFILES=10
WRITESTR=AELD_IS_FUN
WRITEDIR=/tmp/aeld-data
username=$(cat conf/username.txt)



if [ $# -lt 3 ]
then
	echo "Using default value ${WRITESTR} for string to write"
	if [ $# -lt 1 ]
	then
		echo "Using default value ${NUMFILES} for number of files to write"
	else
		NUMFILES=$1
	fi	
else
	NUMFILES=$1
	WRITESTR=$2
	WRITEDIR=/tmp/aeld-data/$3
fi

MATCHSTR="The number of files are ${NUMFILES} and the number of matching lines are ${NUMFILES}"

echo "Writing ${NUMFILES} files containing string ${WRITESTR} to ${WRITEDIR}"



# create $WRITEDIR if not assignment1
assignment=`cat conf/assignment.txt`

echo "Removing the old writer utility and compiling as a native application"

#make

mkdir -p tmp/aeld-data
echo "creating a directory"
for i in $( seq 1 $NUMFILES)
do	
	
	echo "######"
	
	touch ./tmp/aeld-data/kal997$i.txt
	./writer tmp/aeld-data/kal997$i.txt $WRITESTR
	
done


OUTPUTSTRING=$(./finder.sh "$WRITEDIR/" "$WRITESTR")

for i in $( seq 1 $NUMFILES)
do	
	rm tmp/aeld-data/kal997$i.txt 
	touch tmp/aeld-data/kal997$i.txt
done

echo $OUTPUTSTRING
pwd

set +e
echo "${OUTPUTSTRING}" | grep "${MATCHSTR}"
if [ $? -eq 0 ]; then
	echo "success"
	exit 0
else
	echo "failed: expected  ${MATCHSTR} in ${OUTPUTSTRING} but instead found"
	exit 1
fi

rm -r tmp
echo "removing tmp directory"


