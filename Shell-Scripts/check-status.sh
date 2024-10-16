#!/bin/bash

host=$1
port=$2

STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$host:$port)
if [ $STATUS -eq 200 ]; then
echo "SUCCESS:ok"
else
echo "FAIL:failed"
fi
