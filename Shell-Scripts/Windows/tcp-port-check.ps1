$a=723
$b=500
if ($a -gt $b) {
    "FAILED"
}
else {
    "SUCCSS"
}



#$dsthreshold= $args[0]
#$drive= $args[1]
#$ErrorActionPreference= 'silentlycontinue'
#
#$FREE_SPACE = Get-Ciminstance Win32_LogicalDisk -Filter "DeviceID='${drive}:'" | ForEach-Object {[math]::truncate($_.freespace / 1GB)}
#$TOTAL_SPACE = Get-Ciminstance Win32_LogicalDisk -Filter "DeviceID='${drive}:'" | ForEach-Object {[math]::truncate($_.size / 1GB)}
#$PERCENTAGE=(($TOTAL_SPACE-$FREE_SPACE)*100)/$TOTAL_SPACE
#    
#if ($null -eq $PERCENTAGE){
#    Write-Host "FAIL:0"
#}else {
#if ($PERCENTAGE -ge $dsthreshold) {
#    Write-Host "FAIL:$PERCENTAGE"
#}
#else {
#    Write-Host "SUCCESS:$PERCENTAGE"
#    }
#}

#$url=$args[0]
#$ErrorActionPreference= 'silentlycontinue'
#$ip=$url -split "//" -split ":" | select -Last 2 | select -First 1
#$port=$url -replace "https://", ""
#echo url: $url
#$port=$url -split "/" 
#echo "$port"
#echo IP:$ip Port:$port

#$t = New-Object Net.Sockets.TcpClient -EA SilentlyContinue
#$t.Connect($Ipaddress,$Port)
#if($t.Connected)
#    {
#        "SUCCESS"
#       }
#    else
#    {
#        "FAILED"
#        }