# Define container names
$containers = @{
    "MongoDB" = "MongoDB"
    "Cassandra" = "Cassandra"
    "PostgreSQL" = "PostgreSQL"
	"YellowHammer-Client" = "YellowHammer-Client"
	"YellowHammer-Server" = "Central-YellowHammer-Server"
	"Hummingbird" = "hummingbird_server"
	"BlueCardinal" = "Bluecardinal-Server"
}

# Function to check if a Docker container is running
function Test-ContainerRunning {
    param (
        [string]$containerName
    )

    try {
        $containerStatus = docker inspect -f '{{.State.Running}}' $containerName
        if ($containerStatus -eq "true") {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

# Function to restart a Docker container
function Restart-Container {
    param (
        [string]$containerName
    )

    try {
        docker restart $containerName
        Write-Output "$containerName container restarted."
    } catch {
        Write-Output "Failed to restart $containerName container."
    }
}

# Main script logic
foreach ($service in $containers.Keys) {
    $containerName = $containers[$service]
    if (Test-ContainerRunning -containerName $containerName) {
        Write-Output "$service is running."
    } else {
        Write-Output "$service is not running. Restarting the container..."
        Restart-Container -containerName $containerName
    }
}
