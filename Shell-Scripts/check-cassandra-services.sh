#!/bin/bash

WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/e3b93b2d-28d0-4980-a45d-a527b106f5ba@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/8db0277325e042c0be9423f66a97792a/8f5ab347-0cc4-4385-a266-1ba4fc6adf2e"

cqlsh -e "SHOW VERSION" > /dev/null 2>&1

if [ $? -ne 0 ]; then

	curl -H "Content-Type: application/json" -d '{"text": "Cassandra server is stop please check immediately."}'  "${WEBHOOK_URL}"
fi
   
