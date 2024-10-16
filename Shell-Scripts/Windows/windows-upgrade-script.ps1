$Service_Name="YellowHammer-Client" #service name.
$YH_CLIENTPATH="C:\SigmaStream\YellowHammer\YellowHammer-WebClient\yellowhammer-webclient" #App installation path.
$UPGRADE_BUNDLE_PATH="C:\SigmaStream\yellowhammer-client.zip" #Upgrade zip filepath.
$TOOLSDIR="C:\SigmaStream\Tools\" #Tools directory for bundle extract.
$ZIPSOURCEPATH="C:\Program Files\7-Zip\" #7zip path which has 7z.exe file.
$BACKUPDIR="C:\SigmaStream\Tools\Backup\$Service_Name" #Path to store backup file.
$BUNDLENAME="C:\SigmaStream\YellowHammer\YellowHammer-WebClient\" #folder name where app is installed.
$BACKUPNAME="YellowHammer-Client_110.zip" #backup file name
$OLDBACKUPNAME="C:\SigmaStream\Tools\Backup\$Service_Name\" #old backup file name for deleting purpose.
$curdir=(Get-Location).Path #current directory to get back once execution is completed.

#TODO
#- Fix the excluding log files in backup function.
    # Add option to remove OLDBACKUP.
# //TODO -> Restore backup feature.

function validateinputs() {
    #validate service name
    # $ErrorActionPreference = 'silentlycontinue'
    # Get-Service -Name $Service_Name 
    if (-not (Get-Service -Name $Service_Name)) {
        Write-Warning "[!] Invalid service name ($Service_Name), Exiting"
        exit
    }
    #validate inputpath
    # Test-Path $YH_CLIENTPATH 
    if ( -not (Test-Path "$YH_CLIENTPATH") ) {
        Write-Warning "[!] Can not verify the application path ($YH_CLIENTPATH), Exiting"
        exit
    }
    # Test-Path $UPGRADE_BUNDLE_PATH
    if ( -not (Test-Path "$UPGRADE_BUNDLE_PATH")){
        Write-Warning "[!] Can not verify the upgrade bundle on path ($UPGRADE_BUNDLE_PATH), Exiting"
        exit 1
    }
    #validate zip file path
    # Test-Path "$ZIPSOURCEPATH" 
    if ( -not (Test-Path "$ZIPSOURCEPATH") ) {
        Write-Warning "[!] Unable to verify zip utility at ($ZIPSOURCEPATH\7z.exe) 7Zip utility must be installed to use this script, Exiting. Download 7-Zip from
        https://www.7-zip.org/a/7z1900-x64.exe"
        exit 1
    } else {
        $env:Path += ";$ZIPSOURCEPATH"
    }
    #validate and create backup directory if not exist
    # Test-Path "$BACKUPDIR" 
    if ( -not (Test-Path "$BACKUPDIR") ) {
        Write-Warning `t"[#] No backup path found, creating it ($BACKUPDIR)"    
        mkdir $BACKUPDIR > $null
    }
    if ( -not (Test-Path "$TOOLSDIR") ) {
        Write-Warning `t"[#] Can not verify Tools directory, creating it ($TOOLSDIR)"    
        mkdir $TOOLSDIR > $null
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

#------------------Action Block-------------------#
#Check if all given inputs are valid by validating the path and files.
#Validate inputs.
Write-Output "[+] Validating environment, before upgrade."
validateinputs
7z.exe > $null #Fail safe if 7z.exe not found.
if ($?) {
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
} else
 {
    Write-Warning "[!] Unable to verify the 7zip installation, please make sure, It's installed by running 7z.exe command."
 }

