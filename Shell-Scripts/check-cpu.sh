#!/bin/bash

cpu_limit=$1
app_name=$2

if [ "$app_name" == "" ]; then
        echo "FAIL:Empty String"
else
        appCpu=$(ps aux | grep -v grep | grep "${app_name}" | awk '{print $3}' |head -1)
        # echo "appCPU: $appCpu"

        if [ "${appCpu}" -ge "${cpu_limit}" ]; then
                echo "FAIL:$appCpu"
        else
                echo "SUCCESS:$appCpu"
        fi
fi