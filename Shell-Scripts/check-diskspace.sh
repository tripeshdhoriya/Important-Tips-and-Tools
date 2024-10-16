#!/bin/bash

threshold=$1
mount=$2
df -h "${mount}" > /dev/null 2>&1
if [ $? -eq 0 ]; then
        diskusage=$(df -h "${mount}" --output=used | tail -1 | tr -d ' ')
        disksize=$(df -h "${mount}" --output=size | tail -1 | tr -d ' ')
        usagepcent=$(df -h "${mount}" --output=pcent | tail -1 | tr -d ' ' | tr -d '%')
        if [ "${usagepcent}" -gt "${threshold}" ]; then
                echo "FAIL:${mount}:${disksize}:${diskusage}:${usagepcent}(%)"
        else
                echo "SUCCESS:${mount}:${disksize}:${diskusage}:${usagepcent}(%)"
        fi
else
	echo "FAIL:NaN"
fi
