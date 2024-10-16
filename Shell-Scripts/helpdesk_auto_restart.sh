#!/bin/bash

# Set the threshold for load average
threshold=5

# Microsoft Teams webhook URL
teams_webhook_url="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/5c2cd4aefc6a4cc798696536f61a6c24/d8146787-3eaa-4062-b82f-845f245f689f"


#Get the 1-minute load average
load_average=$(uptime | awk -F'average:' '{print $2}' | awk '{print $1}')

# Compare the load average with the threshold
if (( $(echo "$load_average > $threshold" | bc -l) )); then
    echo "Load average is high ($load_average). Restarting MySQL service..."
    
    # Restart MySQL service
    systemctl restart mysql
    
    if [ $? -eq 0 ]; then
        echo "MySQL service restarted successfully."

        # Send alert to Microsoft Teams
        alert_message="HelpDesk was restarted due to high load average.($load_average)."
        curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"$alert_message\"}" $teams_webhook_url
    else
        echo "Failed to restart MySQL service."

	# Send alert to Microsoft Teams
        alert_message="HelpDesk was not restarted properly. Please infomed to Infra Team.($load_average)."
        curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"$alert_message\"}" $teams_webhook_url
    fi
else
    echo "Load average is within acceptable limits ($load_average). No action needed."
fi
