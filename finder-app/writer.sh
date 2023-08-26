#!/bin/bash


num_of_input_params=$#
writefile=$1
writestr=$2

if [ ${num_of_input_params} -ne 2 ];
then
	echo "[ERROR]: invalid input parameters number"
	exit 1

else
	
	mkdir -p .${writefile%/*} 
	if [[ $? -eq 0 ]];
	then
		
		touch .${writefile}
		echo "${writestr}" > ./${writefile}
		exit 0
	else
		exit 0
	fi
		
fi
