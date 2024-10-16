#!/bin/bash
PROCESS_NAME="yellowhammer-server"
#SERVICE_NAME=$2
THREAD_THRESHOLD=5000
RP_LOG=/apps/rcagent/logs/yh_thread_monitor.$(date +%d%m%Y).log
PID=$(/usr/bin/ps -ef |/bin/grep -v grep | /bin/grep -v "watch" |/bin/grep -i ${PROCESS_NAME} | /bin/awk '{print $2}')
WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f"

if [ -z "${PID}" ]; then
    exit 1
fi

OPEN_THREAD=$(/bin/ps -T -p ${PID} | /bin/wc -l )
UPTIME=$(/usr/bin/ps -p ${PID} -o etimes=)

if [ "${OPEN_THREAD}" -gt "${THREAD_THRESHOLD}" ]; then
    echo "WARNING: $(/bin/date) || PID: ${PID} || Current process threads(${OPEN_THREAD}) are above given threshold(${THREAD_THRESHOLD}) || Uptime(m): $((${UPTIME}/60))" >> ${RP_LOG}
    TITLE="`hostname`-East: Thread Warning"
    MESSAGE="WARNING: $(/bin/date) || PID: ${PID} || Threads(${OPEN_THREAD}) are above threshold(${THREAD_THRESHOLD}) || Uptime(m): $((${UPTIME}/60))" | sed 's/"/\"/g' | sed "s/'/\'/g"
    JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
    curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
else 
    echo "INFO: $(/bin/date) || PID: ${PID} || Current process threads(${OPEN_THREAD}) and threshold(${THREAD_THRESHOLD}) || Process Uptime(m): $((${UPTIME}/60))" >> ${RP_LOG}
fi