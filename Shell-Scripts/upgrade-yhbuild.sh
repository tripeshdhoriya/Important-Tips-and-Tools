#!/bin/bash

shopt -s expand_aliases
source ~/.bashrc

YHSERVERDESTDIR=/home/sigmastream/yhserver/yellowhammer-base/webapps/
YHSERVERDIR=/home/sigmastream/yhserver/
YHWEBDESTDIR=/home/sigmastream/yhwebclient/
buildlocation=/home/sigmastream/upgrade-files/
deploybuildfilename=yellowhammer-upgrade.zip

if [ -f ${buildlocation}/${deploybuildfilename} ]; then
    echo "[+] Checking status of YellowHammer-Server service..."
    sudo service yhserver status > /dev/null 2>&1
    if [ $? -eq 0 ]; then 
            echo "[+] Stopping YellowHammer-Server service..."
            sudo service yhserver stop
    else
        echo "[-] YellowHammer-Server service is already stopped."
    fi

    echo "[+] Checking status of YellowHammer-Webclient service..."
    sudo service yhwebclient status > /dev/null 2>&1
    if [ $? -eq 0 ]
        then 
            echo "[+] Stopping YellowHammer-WebClient service..."
            sudo service yhwebclient stop
    else    
        echo "[-] YellowHammer-WebClient service is already stopped."
    fi

    wait
    echo "[+] De-compressing files..."
    cd ${buildlocation} || { echo "Failed to cd ${buildlocation}, EXITING!"; exit 1; }
    unzip -oq ${deploybuildfilename}
    echo "[+] Upgrading YH-SERVER files..."
    sudo rm ${YHSERVERDESTDIR}/ROOT.war > /dev/null
    cp yellowhammer-server/ROOT.war ${YHSERVERDESTDIR}
    
    if [[ -d "${YHSERVERDESTDIR}/ROOT" ]]; then
        echo "found old ROOT directory removing it."
        cd ${YHSERVERDESTDIR} || { echo "Failed to cd ${YHSERVERDESTDIR}, EXITING!" ; exit 1; }
        sudo rm -rf ./ROOT
        mkdir ROOT
        cd - || { echo "Failed to cd into previous directory, EXITING!" ; exit 1; }
    fi
    echo  "[+] Updating time for ROOT.war"
    cd ${YHSERVERDESTDIR} || { echo "Failed to cd ${YHSERVERDESTDIR}, EXITING!"; exit 1; }
    sleep 2
    touch ROOT.war
    cd - || { echo "Failed to cd into previous directory, EXITING!"; exit 1; }
    
    #Cleaning old logs.
    echo -n "[+] Cleaning YellowHammer-Server old logs... "
    sudo rm ${YHSERVERDIR}/logs/gc-* > /dev/null 2>&1
    sudo rm ${YHSERVERDIR}/heapdump/*.hprof > /dev/null 2>&1
    sudo rm ${YHSERVERDIR}/yellowhammer-base/logs/*.log* > /dev/null 2>&1
    echo " [ $GREEN OK $NORMAL ]"
    sudo chown -R sigmastream:sigmastream /apps/yhserver/
    ###
    echo ""

    echo "[+] Upgrading YellowHammer-WebClient..."
    sudo cp yellowhammer-webclient/yh-webclient.jar ${YHWEBDESTDIR} > /dev/null 2>&1
    unzip -oq yellowhammer-webclient/webapp.zip -d ${YHWEBDESTDIR} > /dev/null 2>&1
    sudo rm -rf ${YHWEBDESTDIR}/i18n/ > /dev/null 2>&1
    sudo chown -R sigmastream:sigmastream /apps/yhserver/
    sudo cp -r yellowhammer-webclient/i18n/ ${YHWEBDESTDIR}
    #
    echo -n "[+] Cleaning YellowHammer-WebClient logs... "
    sudo rm ${YHWEBDESTDIR}/logs/*.log* > /dev/null 2>&1
    echo " [ $GREEN OK $NORMAL ]"
    ##

    echo "[+] Removing build files..."
    cd ${buildlocation} || { echo "Failed to cd into ${buildlocation} directory, EXITING!"; exit 1; }
    sudo rm yellowhammer-upgrade.zip
    sudo rm -rf ./yellowhammer-server
    sudo rm -rf ./yellowhammer-webclient
    echo "[+] Starting YellowHammer services.."
    sudo service yhserver start > /dev/null 2>&1
    sleep 5
    sudo service yhwebclient start > /dev/null 2>&1 && exit 0
    exit 0
else
    echo "[!] Upgrade zip file not found at ${buildlocation}/${deploybuildfilename}."
fi
