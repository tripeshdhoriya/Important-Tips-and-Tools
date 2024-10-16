$Service_Name="YellowHammer-Client1"
$YH_CLIENTPATH="C:\SigmaStream\YellowHammer\YellowHammer-WebClient\yellowhammer-webclient"
$UPGRADE_BUNDLE_PATH="C:\SigmaStream\yellowhammer-client.zip"
$TOOLSDIR="C:\SigmaStream\Tools\"
$ZIPSOURCEPATH="C:\Program Files\7-Zip\"
$BACKUPDIR="C:\SigmaStream\Tools\Backup\$Service_Name"
$BUNDLENAME="C:\SigmaStream\YellowHammer\YellowHammer-WebClient\"
$BACKUPNAME="YellowHammer-Client_110.zip"
$OLDBACKUPNAME="C:\SigmaStream\Tools\Backup\$Service_Name\"
$curdir=(Get-Location).Path

#TODO
#- Fix the excluding log files in backup function.
# //TODO -> Restore backup feature.

function validateinputs() {
    #validate service name
    # $ErrorActionPreference = 'silentlycontinue'
    # Get-Service -Name $Service_Name 
    if (-not (Get-Service -Name $Service_Name *> $null )) {
        Write-Warning `t"[!] Invalid service name ($Service_Name), Exiting"
        exit
    }
    #validate inputpath
    # Test-Path $YH_CLIENTPATH 
    if ( -not (Test-Path "$YH_CLIENTPATH") ) {
        Write-Warning "[!] Can not find the application path ($YH_CLIENTPATH), Exiting"
        exit
    }
    # Test-Path $UPGRADE_BUNDLE_PATH
    if ( -not (Test-Path "$UPGRADE_BUNDLE_PATH")){
        Write-Warning "`t [!] Can not find the upgrade bundle on path ($UPGRADE_BUNDLE_PATH), Exiting"
        exit 1
    }
    #validate zip file path
    # Test-Path "$ZIPSOURCEPATH" 
    if ( -not (Test-Path "$ZIPSOURCEPATH") ) {
        Write-Warning "`t [!] Unable to find zip utility at ($ZIPSOURCEPATH). Exiting"
        exit 1
    } else {
        $env:Path += ";$ZIPSOURCEPATH"
    }
    #validate and create backup directory if not exist
    # Test-Path "$BACKUPDIR" 
    if ( -not (Test-Path "$BACKUPDIR") ) {
        Write-Warning "`t [#] No backup path found, creating it ($BACKUPDIR)"    
        mkdir $BACKUPDIR > $null
    }
}

function stopservice () {
    if (((Get-Service -Name "$Service_Name").Status) -eq "Running" ) {
        Write-Output "[+] Stopping service $Service_Name"
        Stop-Service "$Service_Name"
    }else {
        Write-Output "[#] $Service_Name is already stopped."
    }
}

function takebackup() {
    #supress the output message!
    if (-not (Test-Path $BACKUPDIR\$BACKUPNAME)) {
    Write-Output "[+] Taking backup, It may take upto 5 minutes!"
    $env:Path += ";$ZIPSOURCEPATH"
    7z.exe a -tzip $BACKUPDIR\$BACKUPNAME -ax!\logs\* $BUNDLENAME -y *> $Service_Name_bakup.log
    Write-Output "`t [#] Done"
    } else {
        Write-Output "`t [#] Backup File already exists"
    }
}

#---------------Calling Block-------------------#
#Check if all given inputs are valid by validating the path and files.
#Validate inputs.
Write-Output "[+] Validating environment, before upgrade."
validateinputs
Write-Output "`t [#] Validation completed."
#Check service.
stopservice
#Take backup
takebackup
#extract the zip file
Set-Location $TOOLSDIR
7z.exe x $UPGRADE_BUNDLE_PATH -y > $null
if ($?) {
    Set-Location $TOOLSDIR\yellowhammer-client
    if ($?) {
    # Write-Output $PWD
    Write-Output "[+] Upgrading the $Service_Name"
    #replace jar file.
    Move-Item -Force $YH_CLIENTPATH\yh-webclient.jar $YH_CLIENTPATH\yh-webclient_jar
    Copy-Item yh-webclient.jar $YH_CLIENTPATH\
    #replace webapp folder
    Set-Location $YH_CLIENTPATH
    Remove-Item -r .\webapp\
    7z.exe x $TOOLSDIR\yellowhammer-client\webapp.zip > $null
    #Copy i18n changes.
    Set-Location $TOOLSDIR\yellowhammer-client
    Copy-Item -r -Force i18n $YH_CLIENTPATH
    #Applynig config changes if Applynig
    # Get-Content config.properties >> $YH_CLIENTPATH\config\config.properties
    Set-Location $curdir
    #Cleanup time
    Write-Output "`t [#] Removing old logs."
    Remove-Item -Force $YH_CLIENTPATH\logs\*.log*
    Start-Sleep 5
    Remove-Item -r $TOOLSDIR\yellowhammer-client
    Write-Output "[#] Upgrade completed."
    ##
    #Start the service
    Write-Output "[#] Starting the $Service_Name service."
    #Start the service.
    } else {
        print "[!] Failed to Set-Location into $TOOLSDIR\yellowhammer-client"
    }
} else {
    print "[!] Something went wrong while extracting the upgrade bundle file."
}
# dir $TOOLSDIR\YellowHammer-WebClient

