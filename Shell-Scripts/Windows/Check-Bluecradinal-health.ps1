# Define variables
$url = "http://localhost:8181"
$expectedResponse = "Bluecardinal"
$dockerContainerName = "Bluecardinal-Server" # Replace with your Docker container name or ID

# Define the curl command
$curlCommand = "curl.exe -X GET -H 'Accept: */*' $url"

# Execute curl command and capture the output
try {
    # Run the curl command and capture the output
    $output = &cmd /c $curlCommand

    if ($output -eq $expectedResponse) {
        Write-Host "curl request succeeded with response: $output"
    } else {
        Write-Host "Unexpected response from curl: $output. Restarting Docker container..."
        docker restart $dockerContainerName
    }
} catch {
    Write-Host "Error executing curl command: $_. Restarting Docker container..."
    docker restart $dockerContainerName
}
