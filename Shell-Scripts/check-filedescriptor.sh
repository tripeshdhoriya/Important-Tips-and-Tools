#!/bin/bash
PROCESS_NAME=$1
SERVICE_NAME=$2
FD_THRESHOLD=$3
LOGFILE=/apps/rcagent/logs/app_fd_monitor.log
# PID=$(/usr/bin/ps -ef |/bin/grep -v grep | /bin/grep -v "watch" |/bin/grep -i ${PROCESS_NAME} | /bin/grep -i "adempiere" | /bin/awk '{print $2}')
PID=$(/usr/bin/pgrep -if "${PROCESS_NAME}" | head -1)
# echo PID: ${PID}
if [ -z "${PID}" ]; then
    echo "Fail:NaN"
    exit 1
fi

OPEN_FD=$(sudo /bin/ls "/proc/${PID}/fd/" | /bin/wc -l )
FD_LIMIT=$(grep -i "max open files" "/proc/${PID}/limits" | awk '{print $4}')
# echo "${OPEN_FD}"
UPTIME=$(/usr/bin/ps -p "${PID}" -o etimes=)

if [ "${OPEN_FD}" -gt "${FD_THRESHOLD}" ]; then
    echo "FAIL:${OPEN_FD}:${FD_LIMIT}"
    echo "$(/bin/date) || ${PROCESS_NAME} ,PID: ${PID} || FD(${OPEN_FD}) are above threshold(${FD_THRESHOLD}) || Uptime(m): $((${UPTIME}/60))" >> ${LOGFILE}
    sudo /sbin/service "${SERVICE_NAME}" restart
else
    echo "SUCCESS:${OPEN_FD}:${FD_LIMIT}"
fi