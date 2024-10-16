#!/bin/bash
PROCESS_NAME="rockpigeon/server"
# PID=$(pgrep -f "${PROCESS_NAME}")
PID=$(ps -ef  | grep -v grep | grep ${PROCESS_NAME} | awk '{print $2}'| head -1)
TOTAL_OFD=$(sudo ls /proc/${PID}/fd/ | wc -l)
SOCKET_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -ic "socket")
JAR_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep ".jar" | wc -l)
ESTABLISHED_OFD=$(sudo lsof -p ${PID} | grep -c "ESTA") 
CLOSED_OFD=$(sudo lsof -p ${PID} | grep -c "CLOSE")
DELTED_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -c "delete")
LOGFILE_OFD=$(sudo ls -al /proc/${PID}/fd/ | grep -c ".log")
#MONGODB_OFD=$(sudo lsof -p ${PID} | grep -c "27017")
#SOCKET_MONGODB_CONN=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c "5432")
SOCKET_HTTP_CONN=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c "https")
PIPE_OFD=$(sudo lsof -p ${PID} | grep -c "pipe")
#IoTConn=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c 8883)
YHUSWEST_LOCAL_CONN=$(sudo lsof -p ${PID} | grep "ESTA" | grep -c " rockpigeon-useast")
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
COLOR=00008B
message="${time} || ProcessName=${PROCESS_NAME} || PID=${PID} <br><strong>Total_OFD=${TOTAL_OFD}</strong><br> SOCKET_OFD=${SOCKET_OFD} <br> JAR_OFD=${JAR_OFD} <br> ESTABLISHED_OFD=${ESTABLISHED_OFD} <br> CLOSED_OFD=${CLOSED_OFD} <br> DELETED_OFD=${DELTED_OFD} <br> LOGFILE_OFD=${LOGFILE_OFD} <br> SOCKET_HTTP_CONN=${SOCKET_HTTP_CONN} <br> PIPE_OFD=${PIPE_OFD} <br> RUSEAST-LOCAL=${YHUSWEST_LOCAL_CONN}"

echo "Time=${time} || ProcessName=${PROCESS_NAME} || PID=${PID} <br><strong>Total_OFD=${TOTAL_OFD}</strong><br> SOCKET_OFD=${SOCKET_OFD} <br> JAR_OFD=${JAR_OFD} <br> ESTABLISHED_OFD=${ESTABLISHED_OFD} <br> CLOSED_OFD=${CLOSED_OFD} <br> DELETED_OFD=${DELTED_OFD} <br> LOGFILE_OFD=${LOGFILE_OFD} <br> SOCKET_HTTP_CONN=${SOCKET_HTTP_CONN} <br> PIPE_OFD=${PIPE_OFD} <br> RUSEAST-LOCAL=${YHUSWEST_LOCAL_CONN}" >> /apps/rcagent/logs/rp_west_fd_track.html
echo "==============================================" >> /apps/rcagent/logs/rp_west_fd_track.html

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
sendalert $message


# printf "$PID \t $PROCESS_NAME \t $TOTAL_OFD \t $SOCKET_OFD $JAR_OFD \t $ESTABLISHED_OFD \t $CLOSED_OFD"
