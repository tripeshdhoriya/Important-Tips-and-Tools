#!/bin/bash
PROCESS_NAME="yellowhammer-server"
# PID=$(pgrep -f "${PROCESS_NAME}")
PID=$(ps -ef  | grep -v grep | grep ${PROCESS_NAME} | awk '{print $2}'| head -1)
MONITOR_IP=20.185.91.116
TOTAL_OFD=$(sudo ls /proc/${PID}/fd/ | wc -l)
SOCKET_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -ic "socket:")
JAR_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -c ".jar")
ESTABLISHED_OFD=$(sudo lsof -p ${PID} | grep -c "ESTA") 
CLOSED_OFD=$(sudo lsof -p ${PID} | grep -c "CLOSE")
DELTED_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -c "delete")
LOGFILE_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -c ".log")
MONGODB_OFD=$(sudo lsof -p ${PID} | grep -c "27017")
SOCKET_MONGODB_CONN=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c "27017")
SOCKET_HTTP_CONN=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c "https")
PIPE_OFD=$(sudo lsof -p ${PID} | grep -c "pipe")
IoTConn=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c :8883)
YHUSWEST_LOCAL_CONN=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c yhus)
IP_MON=$(sudo lsof -p ${PID}  | grep -c $MONITOR_IP)
LOGFILE=/apps/rcagent/logs/ofd-monitor.log
PG_CONNECTION=$(sudo netstat -apn | grep "40.71.8.203" | grep 5432 | grep -i "established" | wc -l)
#CVX-TEST
WEBHOOK_URL=https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/2e50a843414a4301ba6db579b1b3464e/d8146787-3eaa-4062-b82f-845f245f689f
#https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/2e50a843414a4301ba6db579b1b3464e/d8146787-3eaa-4062-b82f-845f245f689f
alertstatus=TRUE
time=$(date |tr ':' '-')
function sendalert {
    if [ $alertstatus == "TRUE" ]; then
        # MESSAGE=$(echo $message | sed 's/"/\"/g' | sed "s/'/\'/g" )
        MESSAGE=$message
        # IP=$(echo $ip)
        TITLE="`hostname`:- `echo $ip`"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
    fi
}
COLOR=CBC3E3
message="${time} || ProcessName=${PROCESS_NAME} || PID=${PID} <br><strong>Total_OFD=${TOTAL_OFD}</strong><br> SOCKET_OFD=${SOCKET_OFD} <br> JAR_OFD=${JAR_OFD} <br> ESTABLISHED_OFD=${ESTABLISHED_OFD} <br> CLOSED_OFD=${CLOSED_OFD} <br> DELETED_OFD=${DELTED_OFD} <br> LOGFILE_OFD=${LOGFILE_OFD} <br> MONGODB_OFD=${MONGODB_OFD} <br> SOCKET_MONGODB_CONN=${SOCKET_MONGODB_CONN} <br> SOCKET_HTTP_CONN=${SOCKET_HTTP_CONN} <br> PIPE_OFD=${PIPE_OFD} <br> IoTHubConn=${IoTConn} <br> YHUSWEST_LOCAL=${YHUSWEST_LOCAL_CONN} <br> IP($MONITOR_IP)=${IP_MON} <br> PostgreSQL-Connection=${PG_CONNECTION}"

sendalert $message

echo "${time} || ProcessName=${PROCESS_NAME} || PID=${PID} Total_OFD=${TOTAL_OFD} || SOCKET_OFD=${SOCKET_OFD} || JAR_OFD=${JAR_OFD} || ESTABLISHED_OFD=${ESTABLISHED_OFD} || CLOSED_OFD=${CLOSED_OFD} ||  DELETED_OFD=${DELTED_OFD} ||  LOGFILE_OFD=${LOGFILE_OFD} || MONGODB_OFD=${MONGODB_OFD} || SOCKET_MONGODB_CONN=${SOCKET_MONGODB_CONN} || SOCKET_HTTP_CONN=${SOCKET_HTTP_CONN} || PIPE_OFD=${PIPE_OFD} || IoTHubConn=${IoTConn} || YHUSWEST_LOCAL=${YHUSWEST_LOCAL_CONN} || IP($MONITOR_IP)=${IP_MON}" >> $LOGFILE

# message="""
# ProcessName=${PROCESS_NAME}
# PID=${PID}
# Total_OFD=${TOTAL_OFD}
# SOCKET_OFD=${SOCKET_OFD}
# JAR_OFD=${JAR_OFD}
# ESTABLISHED_OFD=${ESTABLISHED_OFD}
# CLOSED_OFD=${CLOSED_OFD}
# DELTED_OFD=${DELTED_OFD}
# LOGFILE_OFD=${LOGFILE_OFD}
# MONGODB_OFD=${MONGODB_OFD}
# SOCKET_MONGODB_CONN=${SOCKET_MONGODB_CONN}
# SOCKET_HTTP_CONN=${SOCKET_HTTP_CONN}
# PIPE_OFD=${PIPE_OFD}
# """

unset PID
# printf "$PID \t $PROCESS_NAME \t $TOTAL_OFD \t $SOCKET_OFD $JAR_OFD \t $ESTABLISHED_OFD \t $CLOSED_OFD"
