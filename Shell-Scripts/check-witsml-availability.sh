#!/bin/bash
# set -x
#java_path="/apps/rpserver/jdk-11/bin/java"
jar_path="/apps/Tools/witsml-reader-0.0.2.jar"
store_url="https://20.185.198.143/WITSMLStore/services/Store"
outfile="/tmp/getcap-out"
WEBHOOK_URL=https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/2c36de3e23fa434d9e72120617a85cbb/d8146787-3eaa-4062-b82f-845f245f689f
alertstatus="TRUE"

function sendalert {
    if [ $alertstatus == "TRUE" ]; then
        MESSAGE=$(echo $message | sed 's/"/\"/g' | sed "s/'/\'/g" )
        # IP=$(echo $ip)
        TITLE="`hostname`:- `echo $ip`"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
    else
        return 1
    fi
}

function checkgetcap {
   # GetCapStatus=$($java_path -jar $jar_path url="$store_url" requestType="readCapabilities" | tee $outfile | grep "WITSML Version" | wc -l)
    GetCapStatus=$(/apps/rpserver/jdk-11/bin/java -jar $jar_path url="$store_url" requestType="readCapabilities" | tee $outfile | grep "WITSML Version" | wc -l  )
   if [ $GetCapStatus -lt 1 ]; then
        getlastupdatedtime
        message="$TIMECHECK | WARNING: RockPigeon GetCap request failed, please verify RockPigeon & PostgresSQL access. $GetCapStatus $Output"
        COLOR=FFA500
        sendalert $message
    fi
    rm $outfile
}

checkgetcap
