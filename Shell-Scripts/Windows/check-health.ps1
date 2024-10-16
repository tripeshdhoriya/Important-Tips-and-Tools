$url = "http//:127.0.0.1:80"
$serviceName = "HummingBird"
$teamsWebhookUrl = "
https://sigmastreamcom.webhook.office.com/webhookb2/e3b93b2d-28d0-4980-a45d-a527b106f5ba@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/8db0277325e042c0be9423f66a97792a/8f5ab347-0cc4-4385-a266-1ba4fc6adf2e
"
# Function to check if the URL is accessible
function Test-Url {
    param (
        [string]$url
    )
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

# Function to restart the Windows service
function Restart-Service {
    param (
        [string]$serviceName
    )
    Restart-Service -Name $serviceName
}

# Function to send alert to Microsoft Teams
function Send-TeamsAlert {
    param (
        [string]$webhookUrl,
        [string]$message
    )
    $payload = @{
        "@type" = "MessageCard"
        "@context" = "http://schema.org/extensions"
        "summary" = "Service Alert"
        "themeColor" = "0076D7"
        "sections" = @(
            @{
                "activityTitle" = "Service Alert"
                "activitySubtitle" = $message
            }
        )
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json"
}

# Check if the URL is accessible
if (-not (Test-Url -url $url)) {
    $errorMessage = "URL is not accessible. Restarting service..."
    
    # Restart the Windows service
    Restart-Service -serviceName $serviceName
    
    Write-Host "Service restarted."
    
    # Send alert to Microsoft Teams
    Send-TeamsAlert -webhookUrl $teamsWebhookUrl -message $errorMessage
} else {
    Write-Host "URL is accessible."
}