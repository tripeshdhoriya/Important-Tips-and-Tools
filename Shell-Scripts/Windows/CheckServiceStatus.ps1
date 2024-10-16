# Define the service name
$serviceName = "MongoDB"

# Get the service status
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Output "Service '$serviceName' not found."
} else {
    if ($service.Status -eq 'Stopped') {
        Write-Output "Service '$serviceName' is stopped. Starting it now..."
        Start-Service -Name $serviceName
        if ($?) {
            Write-Output "Service '$serviceName' started successfully."
        } else {
            Write-Output "Failed to start service '$serviceName'."
        }
    } else {
        Write-Output "Service '$serviceName' is already running."
    }
}
