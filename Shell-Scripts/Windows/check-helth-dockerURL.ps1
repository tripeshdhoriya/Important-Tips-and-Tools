# Define the URLs and container names
#$Urls = @("http://localhost:8095", "http://localhost:80", "http://localhost:8181")
$Urls = @("http://localhost:8095", "http://localhost:80")
$ContainerNames = @("Central-YellowHammer-Server", "hummingbird_server")

# Function to check if a URL is reachable using curl
function Check-Url {
    param (
        [string]$url
    )

    $response = curl.exe -s --head --request GET $url
    return $response -match "HTTP/1.1 200 OK" -or $response -match "HTTP/1.1 302 Found"
}

# Initialize a flag to track if all URLs are reachable
$AllUrlsReachable = $true

# Loop through all URLs and check their reachability
for ($i = 0; $i -lt $Urls.Count; $i++) {
    $url = $Urls[$i]
    $containerName = $ContainerNames[$i]

    $result = Check-Url -url $url

    if (-not $result) {
        $AllUrlsReachable = $false
        Write-Host "URL $url is unreachable. Restarting container $containerName..."

        # Restart the specific Docker container
        docker restart $containerName
    } else {
        Write-Host "URL $url is reachable."
    }
}

# If none of the URLs are reachable, restart all containers
if (-not $AllUrlsReachable) {
    Write-Host "None of the URLs are reachable. Restarting all containers..."

    # Stop all running Docker containers
    docker stop $(docker ps -q)

    # Bring all containers back up using docker-compose
    Write-Host "Bringing all containers back up..."
    docker-compose -f "C:\SigmaStream\Tools\SigmaStream\SigmaStream\docker-compose.yml" up -d
} else {
    Write-Host "At least one URL is reachable. No need to stop and restart all containers."
}
