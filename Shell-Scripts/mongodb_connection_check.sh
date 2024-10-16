#!/bin/bash

WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f"

# Store the connection string in a variable
conn_string="mongodb://mongodb2-useast.eastus.cloudapp.azure.com"

# Use the mongo shell to check the connection
mongo "$conn_string" --eval "printjson(db.runCommand({ ping: 1 }))"

# Check the exit status of the mongo shell command
if [ $? -ne 0 ]; then

	curl -H "Content-Type: application/json" -d '{"text": "Connection failed between Chevron-Yellowhammer-SaaS and MongoDB cluster"}'  "${WEBHOOK_URL}"
fi
