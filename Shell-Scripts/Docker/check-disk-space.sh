#!/bin/bash

disk="/dev/root"
freeSpaceGB=$(df -BG "$disk" | awk 'NR==2 {print $4}' | tr -d 'G')

if [ "$freeSpaceGB" -lt 10 ]; then
    # Prepare message
    message="Veras APPNODE have Low disk space on $disk! Free space is ${freeSpaceGB}GB. Please immediately contact to Infra Team"

    # Teams webhook URL
    teamsWebhookUrl="https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f"

    # Send alert to Teams
    curl -H "Content-Type: application/json" -d "{\"text\":\"$message\"}" "$teamsWebhookUrl"
fi
