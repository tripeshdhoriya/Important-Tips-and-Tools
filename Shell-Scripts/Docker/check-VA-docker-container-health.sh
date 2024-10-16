#!/bin/bash

URL="http://20.163.157.64:8081/veras/"
CONTAINER_NAME="veras"
TEAMS_WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f"

if curl -sSf $URL; then
    echo "URL is accessible."
else
    echo "URL is not accessible. Restarting Docker container..."
    docker restart $CONTAINER_NAME
    # Send notification to Teams
    curl -X POST -H 'Content-Type: application/json' -d '{"text":"The Veras agent server is down. Please check the logs and inform the infra team. Currently, the server has been automatically restarted. Please ensure that the server is running properly : '$CONTAINER_NAME'."}' $TEAMS_WEBHOOK_URL
	fi