#!/bin/bash

scheme=$1
host=$2
port=$3
contextpath=$4
url=$scheme://$host:$port/$contextpath

curl -k "$scheme"://"$host":"$port"/"$contextpath" > /dev/null 2>&1
err=$?

if [ $err -gt 0 ]; then
        echo "FAIL:$url"
else
        echo "SUCCESS:$url"
fi