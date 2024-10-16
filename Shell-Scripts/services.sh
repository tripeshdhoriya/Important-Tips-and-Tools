#!/bin/bash

echo "enter the service name:"

read service

#pid="$(pgrep -f -u root $service | head -n 1)" &&  ps -p $pid -o %cpu --no-headers && ps -p $pid -o %mem --no-headers

pid=$(pgrep -f -u root $service | head -n 1)

cpu=$(ps -p $pid -o %cpu --no-headers)

ram=$(ps -p $pid -o %mem --no-headers)

fdcount=$(lsof -p $pid | wc -l)

echo "process id : $pid"

echo "CPU usage : $cpu"

echo "RAM usage : $ram"

echo "FD counts : $fdcount"
