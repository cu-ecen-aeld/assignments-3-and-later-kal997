#!/bin/sh



num_of_input_params=$#
filesdir=$1
searchstr=$2

if [ ${num_of_input_params} -ne 2 ];
then
	echo "[ERROR]: invalid input parameters number"
	exit 1

else
	
	if [ ${filesdir}-d ];
	then
		textCount=$(grep -r -o "${searchstr}" .${filesdir} | wc -l)
		fileCount=$(grep -r -l "${searchstr}" .${filesdir} | wc -l)
		echo "The number of files are ${fileCount} and the number of matching lines are ${textCount}"
	       	exit 0
	
	else
		echo "[ERROR]: ${filesdir} is not a directory"
		exit 1
	fi
		
fi
