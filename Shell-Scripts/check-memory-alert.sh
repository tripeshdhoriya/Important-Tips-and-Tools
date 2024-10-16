#!/bin/bash
# set -x
#PENDING FIX ME
freeMem=$(free -m  | head -2 | tail -1 | awk '{print $4}')
threshold=150
WEBHOOK_URL=https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f
alertstatus=TRUE

function sendalert {
    # if [ $alertstatus == "TRUE" ]; then
        MESSAGE=$(echo $message | sed 's/"/\"/g' | sed "s/'/\'/g" )
        # IP=$(echo $ip)
        TITLE="`hostname`East:- `echo $ip`"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
    # else
        # return 1
    # fi
}

if [ "${freeMem%%.*}" -lt "${threshold}" ]; then
	echo "ALERT: $(date) ||  Available memory ($freeMem) is below threshold($threshold)" >>  /tmp/mem.log
	echo "$(free -h)" >> /tmp/mem.log
    COLOR=ffff00
	message="Available memory($freeMem) is below threshold($threshold)" 
	sendalert $message
else
	echo
	#echo "$(date)" >> /tmp/mem.log
	#echo "INFO: Available memory ($freeMem) is below threshold($threshold)" >>  /tmp/mem.log
	#echo "$(free -h)" >> /tmp/mem.log
	#echo "`date` || $availableMem" | tee /tmp/mem.log
fi

