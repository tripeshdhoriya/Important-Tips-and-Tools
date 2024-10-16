$service_name = $args[0] #Valid Windows service name.
$service_state = $args[1] ##Running, Stopped
$handle_threshold = $args[2] #Integer
$pcpu_threshold = $args[3] #Integer
$pmem_threshold = $args[4] #Integer
$sysload_threshold = $args[5] #Integer
$dsthreshold = $args[6] #Percentage
$drive = $args[7] #Partition to Monitor
$url = $args[8] ## https://127.0.0.1:8447
$logpath = $args[9] ## C:\SigmaStream\YellowHammer-Client\logs\yh_wc_monitor.log

#service name argument check
if ($service_name -and $handle_threshold -and $service_state -and $pcpu_threshold -and $sysload_threshold -and $drive -and $service_state -and $url -and $logpath) {
    #service name validation check.
    Get-Service -Name $service_name > $null
    if ($?) {
        # skipsslcheck 2>&1 | out-null
        $s_state = Get-Service -Name $service_name | Format-List | findstr "Status"
        $s_state = $s_state -split ": "  | Select-Object -last 1
        # Write-Output "Service State: $s_state"
        if ($s_state -eq $service_state) {
            Write-Output "Service is in desire state($service_state)"
            #Get process ID
            $p = Tasklist /svc /fi "SERVICES eq $service_name" /fo csv | convertfrom-csv
            $out_pid = $p -split "=" -split ";" | Select-Object -Last 3 | Select-Object -First 1
            Write-Output "PID: $out_pid"

            if ($out_pid) {
                #Check Diskspace
                Get-Volume -DriveLetter $drive  2>&1 | out-null
                if ($?) {
                    $FREE_SPACE = Get-Ciminstance Win32_LogicalDisk -Filter "DeviceID='${drive}:'" | ForEach-Object { [math]::truncate($_.freespace / 1GB) }
                    $TOTAL_SPACE = Get-Ciminstance Win32_LogicalDisk -Filter "DeviceID='${drive}:'" | ForEach-Object { [math]::truncate($_.size / 1GB) }
                    $PERCENTAGE = (($TOTAL_SPACE - $FREE_SPACE) * 100) / $TOTAL_SPACE
            
                    if ($null -eq $PERCENTAGE) {
                        Write-Output "ERR"
                    }
                    else {
                        if ($PERCENTAGE -ge $dsthreshold) {
                            Write-Output "DSFAILED:($PERCENTAGE)"
                            # $dsres="DSFAILED"
                        }
                        else {
                            Write-Output "DSSUCCESS:($PERCENTAGE)"
                            # $dsres="DSSUCCESS"
                        }
                    }
                }
                else {
                    Write-Output "DISK:ERR"
                }

                ########PORT-CHECK###########
                $Ipaddress = $url -split "//" -split ":" | Select-Object -Last 2 | Select-Object -First 1
                $Port = $url -split "//" -split ":" | Select-Object -Last 2 | Select-Object -Last 1
                $ErrorActionPreference = 'silentlycontinue'
                $t = New-Object Net.Sockets.TcpClient -EA SilentlyContinue
                $t.Connect($Ipaddress, $Port)
                if ($t.Connected) {
                    Write-Output "PORTSUCCESS:($Port)"
                    # $portres= "PORTSUCCESS"
                }
                else {
                    Write-Output "PORTFAILED:($Port)"
                    # $portres="PORTFAILED"
                }
                #####

                ####FILEHANDLES###########
                $handles = (Get-Process | Where-Object 'Id' -eq "$out_pid").Handles
                if ($handles -ge $handle_threshold) {
                    Write-Output "HANDLESFAIL($handles)"
                    # $handleres="HANDLESFAIL"
                } 
                else {
                    Write-Output "HANDLESSUCCESS($handles)"
                    # $handleres="HANDLESSUCCESS"
                }

                ####CURL CHECK###
                if ($url) {
                    $rescode = curl --insecure -s -o /dev/null -w "%{http_code}" ${url}
                    if (! $?) {
                        if ($rescode -ne "200" -and $rescode -ne "302") {
                            Write-Output "CURLFAIL:($rescode)"
                            # $curlres="CURLFAIL"
                        }
                        else {
                            Write-Output "CURLSUCCESS:($rescode)"
                            # $curlres="CURLSUCCESS"
                        }
                    }
                    else {
                        Write-Output "CURL:ERR"
                    }
                }
                else {
                    Write-Output "SKIPCURLCHECK"
                }
                ###
                ###Get CPU Load by Process
                $pcpu = (Get-Process -Id "$out_pid").CPU
                if ($pcpu -ge 0) {
                    if ($pcpu -gt $pcpu_threshold) {
                        Write-Output "PCPUFAILED:($pcpu)"
                        # $pcpures="PCPUFAILED"
                    }
                    else {
                        Write-Output "PCPUSUCCESS:($pcpu)"
                        # $pcpures="PCPUSUCCESS"
                    }
                }
                else {
                    Write-Output "PCPU is =< 0"
                }
                ###Get Process Memory###
                $pmem = ((Get-Process -Id "$out_pid").WS / 1024 / 1024)
                if ($pmem -gt $pmem_threshold) {
                    Write-Output "PMEMFAILED:($pmem)"
                    # $pmemres="PMEMFAILED"
                }
                else {
                    Write-Output "PMSUCCESS:($pmem)"
                    # $pmemres="PMEMSUCCESS"
                }
                ###

                ###Get System Load##
                $sys_load = (Get-CimInstance -Class Win32_Processor).LoadPercentage
                if ($sys_load -gt $sysload_threshold) {
                    # $loadres="SYSLOADFAILED"
                    Write-Output "SYSLOADFAILED:($sys_load)"
                }
                else {
                    # $loadres="SYSLOADSUCCESS"
                    Write-Output "SYSLOADSUCCESS:($sys_load)"
                }
                ###
            

                #--------Action Block---------#
                if (($loadres -eq "SYSLOADFAILED" ) -and ($pcpures -eq "PCPUFAILED" ) -and ($pmemres -eq "PMEMFAILED" )) { 
                    Write-Output "Load, CPU and Memory usage are above threshold."
                    # Write-Output "$(Get-Date) || LoadAVG($sys_load) & CPU Usage($pcpu) and Memory($pmem) Usage is above threshold, Restarting the service($service_name)." >> $logpath
                    # Restart-Service -Name $service_name
                }
                elseif (($loadres -eq "SYSLOADFAILED" ) -and ($pcpures -eq "PCPUFAILED" )) {
                    Write-Output "LoadAVG & CPU Avg are high."
                    # Write-Output "$(Get-Date) || LoadAVG($sys_load) & CPU Usage($pcpu) is above threshold($sysload_threshold ,$pcpu_threshold), Restarting the service($service_name)." >> $logpath
                    # Restart-Service -Name $service_name
                }
                elseif (($portres -eq "PORTFAILED") -and ($curlres -eq "CURLFAIL")) {
                    Write-Output "Port($Port) isn't accessible OR Curl($url) request is failing, Restarting the service"
                    # Write-Output "$(Get-Date) || Port($Port) isn't accessible OR Curl($url) request is failing, Restarting the service($service_name)." >> $logpath
                    # Restart-Service -Name $service_name
                }
                elseif ($portres -eq "PORTFAILED") {
                    Write-Output "Port($Port) isn't accessible, Restarting the service"
                    # Write-Output "$(Get-Date) || Port($Port) isn't accessible, Restarting the service($service_name)." >> $logpath
                    # Restart-Service -Name $service_name
                }
                elseif ($dsres -eq "DSFAILED") {
                    Write-Output "Running out of diskspace($PERCENTAGE), please check."
                    Write-Output "$(Get-Date) || [!] Diskspace($PERCENTAGE) is above threshold($dsthreshold)"
                }
                elseif ($handleres -eq "HANDLESFAIL") {
                    #checkhandles >> $logpath
                    Write-Output "$(Get-Date) || [!] Restarting service($service_name) as filehandles($handles) are above given threshold($handle_threshold)."
                    # Write-Output "$(Get-Date) || [!] NOTRestarting service($service_name) as filehandles($handles) are above given threshold($handle_threshold)." >> $logpath
                    #Restart-Service -Name $service_name
                }
                else {
                    Write-Output "Good for now."
                }
            }
        }
            else {
                Write-Output "[#] Service is not in desire state, getting it in desire state."
                if ($service_state -eq "Running") {
                    Write-Output "$(Get-Date) || [!] Starting service($service_name) as requested in desire state"
                    Start-Service -Name $service_name
                }
                else {
                    Write-Output "$(Get-Date) || [!] Stopping service($service_name) as requested in desire state"
                    # Stop-Service -Name $service_name
                }
            }
        
    }
    else 
    {
        Write-Output "[!] Invalid service name service($service_name) not found!"
    }
}
else {
    Write-Host "[!] One or many arguments are missing!
    Given Inputs:
    ServiceName:[Valid Windows service name]= $service_name	
    ServiceState:[Running, Stopped]= $service_state 	
    FileHandle_Threshold= $handle_threshold
    ProcessCPU_Threshold= $pcpu_threshold	
    ProcessMem_Threshold= $pmem_threshold	
    SysLoad_Threshold= $sysload_threshold
    DiskSpace_Thresholds= $dsthreshold	
    Drive-[Partition to Monitor]= $drive 			
    URL:[https://127.0.0.1:8447]= $url			
    OutputLog:[C:\SigmaStream\YellowHammer-Client\logs\yh_wc_monitor.log]= $logpath"
}