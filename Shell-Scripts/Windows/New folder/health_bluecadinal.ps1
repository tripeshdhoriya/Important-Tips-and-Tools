# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
$SvcName = "Bluecardinalserver"
$status = (Get-Service -Name $SvcName).Status
$baseURI = 'https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f'
$Message = "{""text"": ""Parker Bluecardinal server is down! Please check it.""}"

if ($status -eq 'Running') {
    Write-Host 'Service is Running'
} else {
    # Send alert message to Microsoft Teams
    Invoke-RestMethod -Uri $baseURI -Method Post -Body $Message -ContentType 'application/json'
    Write-Host "Service is not running. Attempting to start..."
    Start-Service -Name $SvcName
    Start-Sleep -Seconds 60
}

$status = (Get-Service -Name $SvcName).Status

if ($status -eq 'Running') {
    Write-Host 'Service is Running'
} else {
    Write-Host "Service is not running after the start attempt."
    # You can add additional actions or alerts here if needed
}

exit
