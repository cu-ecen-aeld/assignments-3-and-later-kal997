#!/bin/bash


num_of_input_params=$#
writefile=$1
writestr=$2

if [ ${num_of_input_params} -ne 2 ];
then
	echo "[ERROR]: invalid input parameters number"
	exit 1

else
	
	ret=$(mkdir -p .${writefile})
	if [[ ${ret} -eq 0 ]];
	then
		rm -r .${writefile}
		touch .${writefile}
		echo "${writestr}" > ./${writefile}
		exit 0
	else
		exit 1
	fi
		
fi
