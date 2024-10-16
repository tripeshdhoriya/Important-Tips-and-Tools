#!/bin/bash
CONNECTION_THRESHOLD=6
WEBHOOK_URL=https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/5c2cd4aefc6a4cc798696536f61a6c24/d8146787-3eaa-4062-b82f-845f245f689f
CURRENT_CONNECTION=$(sudo netstat -apn | grep 5432 | wc -l)
alertstatus=TRUE
function sendalert {
    if [ $alertstatus == "TRUE" ]; then
        MESSAGE=$(echo $message | sed 's/"/\"/g' | sed "s/'/\'/g" )
        # ip=$(curl -k https://ifconfig.info)
        TITLE="$(hostname):- $(curl -sk https://ifconfig.info)"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
        # echo $JSON
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
    else
        return 1
    fi
}

if [ "$CURRENT_CONNECTION" -ge "$CONNECTION_THRESHOLD" ]; then
    echo "[#] Establieshed database connections($CURRENT_CONNECTION) is above given threshold($CONNECTION_THRESHOLD)"
else
    COLOR=F4E98C
    echo "[!] YellowHammer database connections($CURRENT_CONNECTION) are less than given threshold($CONNECTION_THRESHOLD), please monitor it closely."
    message="$(date) || YellowHammer database connections($CURRENT_CONNECTION) are less than given threshold($CONNECTION_THRESHOLD), please monitor it closely."
    sendalert $message
fi
