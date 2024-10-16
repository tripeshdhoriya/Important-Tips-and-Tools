$service_name = $args[0]
$pcpu_threshold = $args[1]
$sysload_threshold = $args[2]
if ($service_name -and $pcpu_threshold -and $sysload_threshold) {

    Get-Service -Name $service_name 2>&1 | Out-Null
    if ($?) {
        #Get process ID
        $p = Tasklist /svc /fi "SERVICES eq $service_name" /fo csv | convertfrom-csv
        $out_pid = $p -split "=" -split ";" | Select-Object -Last 3 | Select-Object -First 1
        Write-Output "PID: $out_pid"
        #
        ###Get CPU Load by Process
        $pcpu = Get-Process | Where-Object 'Id' -eq "$out_pid" | Select-Object 'CPU' | findstr /r "^[0-9]"
        Write-Output "Process CPU: $pcpu"

        ##Get System Load Avg.
        # $sld = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average
        # $sys_load = $sld.Average
        $sys_load=(Get-CimInstance -Class Win32_Processor).LoadPercentage
        Write-Output "System load: $sys_load"

        if ($pcpu -gt $pcpu_threshold) {
            Write-Host "Process CPU usage($pcpu) is above threshold "
            if ($sys_load -gt $sysload_threshold) {
                Write-Host "System load($sys_load) is above threshold!, Restarting the service!!"
                Restart-Service -Name $service_name
            }
        }
        else {
            Write-Host "Life is good!"
        }
    }
    else {
        Write-Host "[!] Service($service_name) not found!"
    }
}
else { 
    Write-Host "[!] One or many arguments are missing!
    Given Inputs:
    Arg1(ServiceName)=$service_name
    Arg2(pcpu_threshold)=$pcpu_threshold
    Arg3(pcpu_threshold)=$sysload_threshold
    "
}