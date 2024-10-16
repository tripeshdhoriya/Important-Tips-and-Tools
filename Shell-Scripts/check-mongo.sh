#!/usr/bin/bash

#RESULT=`pgrep mongo| awk '{print $1}'`  # returns 0 if mongo eval succeeds

#FILTER=$1
#SERVICENAME=$2
HOST=$1
PORT=$2
#RESULT=`ps -ef | grep ${FILTER} | awk -F ' ' '{ if($8=="'"$SERVICENAME"'")  { print $2 } }'`
mongo --host $HOST --port $PORT test --eval "printjson(db.version())" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "SUCCESS:0"
else
   #if [ $RESULT -gt 0 ]; then
    #    echo "SUCCESS:$RESULT"
   #else
    echo "FAIL:0"
   #fi
fi