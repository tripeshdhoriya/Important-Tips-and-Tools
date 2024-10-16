#!/bin/bash
 host="http://127.0.0.1"
 port="52465"
 URL="/api/connection-status"
WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/5c2cd4aefc6a4cc798696536f61a6c24/d8146787-3eaa-4062-b82f-845f245f689f"
#echo  ${host}:${port}${UR--L}
response=""

 curl ${host}:${port}${URL} --connect-timeout 2 > /dev/null
      response=$?
      if [ $response -eq 0 ]; then
              response="SUCCESS"
      else
              response="FAILED"
      fi
 #      exit 1

      if [ $response = "FAILED" ]; then
          curl -H "Content-Type: application/json" -d '{"text": "Bluecardinal server has been stopped."}'  "${WEBHOOK_URL}"


      fi

  #    exit 0
