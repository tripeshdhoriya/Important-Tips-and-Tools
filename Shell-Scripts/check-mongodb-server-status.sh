#!/bin/bash

# Check if mongod service is active
if systemctl is-active --quiet mongod; then
  echo "mongod service is running."
else
  echo "mongod service is not running. Attempting to restart..."

  # Restart the mongod service
  sudo systemctl restart mongod

  # Check if restart was successful
  if systemctl is-active --quiet mongod; then
    STATUS="mongod service was successfully restarted."
  else
    STATUS="Failed to restart mongod service."
  fi

  # Send notification to Microsoft Teams
  WEBHOOK_URL="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f"

  MESSAGE=$(cat <<EOF
{
  "@type": "MessageCard",
  "@context": "http://schema.org/extensions",
  "summary": "mongod service status alert",
  "themeColor": "FF0000",
  "title": "PDC-Well-172.203.217.166",
  "text": "Mongodb service is stopped on PDC-Well Server (RP-witsml2-datastore: 172.203.217.166). Please check and verify. If it is not started automatically, then please contact the IT infra team. Status: $STATUS"
}
EOF
)

  curl -H "Content-Type: application/json" -d "$MESSAGE" $WEBHOOK_URL
fi

