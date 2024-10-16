#!/bin/bash

threshold=$1

# freeMem=`vmstat -s|grep "free memory"|awk '{print $1}'`

usedMem=$(vmstat -s | awk  ' $0 ~ /total memory/ {total=$1 } $0 ~/free memory/ {free=$1} $0 ~/buffer memory/ {buffer=$1} $0 ~/cache/ {cache=$1} END{print (total-free-buffer-cache)/total*100}')
usedMem=${usedMem%.*}
availableMem=$((100-usedMem))

if [ "${usedMem%%.*}" -gt "${threshold}" ]; then
        echo "FAIL:$usedMem:$availableMem"
else
        echo "SUCCESS:$usedMem:$availableMem"
fi
