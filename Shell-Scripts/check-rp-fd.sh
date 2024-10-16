#!/bin/bash
PROCESS_NAME=$1
SERVICE_NAME=$2
FD_THRESHOLD=$3
RP_LOG=/apps/rpserver/log/rp_monitor.log
PID=$(/usr/bin/ps -ef |/bin/grep -v grep | /bin/grep -v "watch" |/bin/grep -i ${PROCESS_NAME} | /bin/grep -i "adempiere" | /bin/awk '{print $2}')

if [ -z "${PID}" ]; then
    exit 1
fi

OPEN_FD=$(/bin/ls /proc/${PID}/fd | /bin/wc -l )
UPTIME=$(/usr/bin/ps -p ${PID} -o etimes=)

if [ "${OPEN_FD}" -gt "${FD_THRESHOLD}" ]; then
    echo "$(/bin/date) || PID: ${PID} || FD(${OPEN_FD}) are above threshold(${FD_THRESHOLD}) || Uptime(m): $((${UPTIME}/60))" >> ${RP_LOG}
    echo "SigmaStream#1" | sudo -S /sbin/service ${SERVICE_NAME} restart
fi