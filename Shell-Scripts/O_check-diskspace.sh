#!/bin/bash

threshold=$1
mount=$2

numLines=`df -h|grep ${mount}|grep -v grep|wc -l`
if [ "${numLines}" -eq 1 ]; then  
	 usage=`df -h|grep ${mount}|grep -v grep|awk '{print $5}'|awk -F% '{print $1}'`
        if [ "${usage}" -gt "${threshold}" ]; then
                echo "FAIL:$usage"
        else
                echo "SUCCESS:$usage"
        fi
else
	echo "FAIL:NAN"
fi
