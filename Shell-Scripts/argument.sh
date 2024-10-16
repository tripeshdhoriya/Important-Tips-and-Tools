#1/bin/bash




echo  "eneter the service name:"

read service

pid="$(pgrep -f -u root  $service | head -n 1)" && ps -p $pid -o %cpu && ps -p $pid -o %mem

echo "$pid"

~
