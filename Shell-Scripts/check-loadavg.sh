#!/bin/bash

threshold=$1
INPUT=$(uptime)
SUBSTRING=$(sed 's#.*:##g' <<< "$INPUT")

loadAvg=$(echo "$SUBSTRING" | cut -d',' -f1)
loadAvg=${loadAvg%.*}
#if test fails you get a 0
# compareResult=$("${loadAvg} > ${threshold}")
# compareResult=${compareResult%.*}

#if [ "${compareResult}" -eq "0" ]; then
if [ "${loadAvg}" -lt "${threshold}" ]; then
        echo "SUCCESS:$loadAvg"
else
        echo "FAIL:$loadAvg"
fi
