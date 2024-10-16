#!/bin/bash
# Checking the Service Status
service=$1
if [ -z "$service" ]; then
echo "usage: $0 <service-name>"
exit 1
fi
echo "Checking $service status"
STATUS="$(systemctl is-active $service)"
RUNNING="$(systemctl show -p SubState $service | cut -d'=' -f2)"
if [ "${STATUS}" = "active" ]; then
echo "$service Service is Active"
if [ "${RUNNING}" = "running" ]; then
echo "$service Service is Running"
else
echo "$service Service Not Running"
fi
else
echo "$service Service not Active "
exit 1
fi