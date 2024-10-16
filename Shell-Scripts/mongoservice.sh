#!/bin/bash
# Checking the Service Status
WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/5c2cd4aefc6a4cc798696536f61a6c24/d8146787-3eaa-4062-b82f-845f245f689f"
#echo  ${host}:${port}${UR--L}
#response=""

service=mongod
if [ -z "$service" ]; then
echo "usage: $0 <service-name>"
exit 1
fi
echo "Checking $service status"
STATUS="$(systemctl is-active $service)"
RUNNING="$(systemctl show -p SubState $service | cut -d'=' -f2)"
if [ "${STATUS}" =  "active" ]; then
echo "$service Service is Active"
else
echo "$service Service not Active"
fi
#exit 1
if [ "${STATUS}" !=  "active" ]; then
	curl -H "Content-Type: application/json" -d '{"text": "Whitecap mongodb server is crashed"}'  "${WEBHOOK_URL}"
fi
exit 0
