#!/bin/bash

export JAVA_HOME=/sigmastream/java
export PATH=$JAVA_HOME/bin:$PATH

heap_dump_dir="/sigmastream/yellowhammer/yellowhammer-server/heapdump/"
heap_dump_file="$heap_dump_dir/cheap.hprof"
process_name="yellowhammer-server"
curl_url="http://localhost:8095"
teams_webhook_url="https://sigmastreamcom.webhook.office.com/webhookb2/e3b93b2d-28d0-4980-a45d-a527b106f5ba@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/8db0277325e042c0be9423f66a97792a/8f5ab347-0cc4-4385-a266-1ba4fc6adf2e"


process_PID=$(/usr/bin/pgrep -f "$process_name" | head -1)
# Function to check the accessibility of the curl URL
check_url_accessibility() {
    if curl --output /dev/null --silent --head --fail "$1"; then
        return 0 # URL is accessible
    else
        return 1 # URL is not accessible
    fi
}

# Function to send a notification to Microsoft Teams
send_teams_notification() {
    local message="$1"
    curl -H "Content-Type: application/json" -d "{\"text\": \"$message\"}" "$teams_webhook_url"
}

# Check if the curl URL is not accessible
if ! check_url_accessibility "$curl_url"; then
    # Send a Teams notification
    teams_message="Alert: The URL $curl_url is not accessible. Heap dump check initiated."
    send_teams_notification "$teams_message"

    # Check if the heap dump file exists
    if [ -e "$heap_dump_file" ]; then
        # Get the last modification time of the heap dump file
        last_modification_time=$(stat -c %Y "$heap_dump_file")

        # Get the current time
        current_time=$(date +%s)

        # Calculate the time difference in minutes
        time_difference=$(( (current_time - last_modification_time) / 60 ))

        # Check if the heap dump file is older than 30 minutes
        if [ "$time_difference" -gt 30 ]; then
            echo "Heap dump file is older than 30 minutes. Generating a new heap dump..."
            jmap -dump:format=b,file="$heap_dump_file" "$process_PID"
        else
            echo "Heap dump file is not older than 30 minutes. No need to generate a new heap dump."
        fi
    else
        # If the heap dump file does not exist, generate a new one
        echo "Heap dump file does not exist. Generating a new heap dump..."
        jmap -dump:format=b,file="$heap_dump_file" "$process_PID"
    fi
else
    echo "Curl URL is accessible. No need to generate a new heap dump."

    # Send a Teams notification
    teams_message="Info: The URL $curl_url is accessible. No heap dump check needed."
    #send_teams_notification "$teams_message"
fi

