# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
$SvcName = "postgresql-x64-14"
$status = (Write-Host(Get-Service -Name $SvcName).Status)
$curlExe = 'C:\Program Files\curl\bin\curl.exe'
$baseURI = 'https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/4f4369ee48974d199e31f78918f29850/d8146787-3eaa-4062-b82f-845f245f689f'
$curlArg = '-X','POST','-H','accept: application/json','-H','Content-Type: application/json','--data','{ \"text\": \"Parker PDCH01 server PostgreSQL is down!\"}',$baseURI

if ((Get-Service -Name $SvcName).Status -eq 'Running') {
      Write-Host 'Service is Running'
   } else {
      & $curlExe $curlArg
      write-host("Not Running is services")
      Start-Service -Name $SvcName
      Start-Sleep -seconds 60      
   } if ((Get-Service -Name $SvcName).Status -eq 'Running') {
        Write-Host 'Service is Running'
   } else {
      write-host("Service is Starting process....")
      Set-Service $SvcName -StartupType manual
      Start-Sleep -seconds 10
}
exit
