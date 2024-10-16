#!/bin/bash
LOGFILE="/tmp/status"
alertstatus=TRUE
WEBHOOK_URL=https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/5c2cd4aefc6a4cc798696536f61a6c24/d8146787-3eaa-4062-b82f-845f245f689f
function checkstatus {
#------variables used------#
S="************************************"
D="-------------------------------------"
COLOR="n"

MOUNT=$(mount|egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs"|grep -v "loop"|sort -u -t' ' -k1,2)
FS_USAGE=$(df -PTh|egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs"|grep -v "loop"|sort -k6n|awk '!seen[$1]++')
IUSAGE=$(df -PThi|egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs"|grep -v "loop"|sort -k6n|awk '!seen[$1]++')

echo -e "$D"
echo -e "\tSystem Health Status"
echo -e "$D"

#--------Print Operating System Details--------#
echo -e "\n<strong>Operating System Details</strong>"
echo -e "$D"

hostname -f &> /dev/null && printf "Hostname : $(hostname -f)" || printf "Hostname : $(hostname -s)"

[ -x /usr/bin/lsb_release ] &&  echo -e "\nOperating System :" $(lsb_release -d|awk -F: '{print $2}'|sed -e 's/^[ \t]*//')  || \
echo -e "\nOperating System :" $(cat /etc/system-release)

echo -e "Kernel Version : " $(uname -r)

printf "OS Architecture : "$(arch | grep x86_64 &> /dev/null) && printf " 64 Bit OS\n"  || printf " 32 Bit OS\n"

#--------Print system uptime-------#
UPTIME=$(uptime)
echo -e $UPTIME|grep day &> /dev/null
if [ $? != 0 ]
then
  echo -e $UPTIME|grep -w min &> /dev/null && echo -e "System Uptime : "$(echo -e $UPTIME|awk '{print $2" by "$3}'|sed -e 's/,.*//g')" minutes" \
 || echo -e "System Uptime : "$(echo -e $UPTIME|awk '{print $2" by "$3" "$4}'|sed -e 's/,.*//g')" hours"
else
  echo -e "<strong>System Uptime : </strong>" $(echo -e $UPTIME|awk '{print $2" by "$3" "$4" "$5" hours"}'|sed -e 's/,//g')
fi
echo -e "Current System Date & Time : "$(date +%c)

#--------Check for any read-only file systems--------#
echo -e "\nChecking For Read-only File System[s]"
echo -e "$D"
echo -e "$MOUNT"|grep -w \(ro\) && echo -e "\n.....Read Only file system[s] found"|| echo -e ".....No read-only file system[s] found. "

#--------Check for currently mounted file systems--------#
echo -e "\n\nChecking For Currently Mounted File System[s]"
echo -e "$D$D"
echo -e "$MOUNT"|column -t

#--------Check disk usage on all mounted file systems--------#
echo -e "\n\n<strong>Checking For Disk Usage On Mounted File System[s]</strong>"
echo -e "$D$D"
echo -e "( 0-90% = OK/HEALTHY, 90-95% = WARNING, 95-100% = CRITICAL )"
echo -e "$D$D"
echo -e "Mounted File System[s] Utilization (Percentage Used):\n"

COL1=$(echo -e "$FS_USAGE"|awk '{print $1 " "$7}')
COL2=$(echo -e "$FS_USAGE"|awk '{print $6}'|sed -e 's/%//g')

for i in $(echo -e "$COL2"); do
{
  if [ $i -ge 95 ]; then
    COLOR=ff0000
    COL3="$(echo -e $i"% $CCOLOR\n$COL3")"
  elif [[ $i -ge 90 && $i -lt 95 ]]; then
    COLOR=ffff00
    COL3="$(echo -e $i"% $WCOLOR\n$COL3")"
  else
    COLOR=add8e6
    COL3="$(echo -e $i"% $GCOLOR\n$COL3")"
  fi
}
done
COL3=$(echo -e "$COL3"|sort -k1n)
paste  <(echo -e "$COL1") <(echo -e "$COL3") -d' '|column -t

#--------Check for any zombie processes--------#
echo -e "\n\nChecking For Zombie Processes"
echo -e "$D"
ps -eo stat|grep -w Z 1>&2 > /dev/null
if [ $? == 0 ]; then
  echo -e "Number of zombie process on the system are :" $(ps -eo stat|grep -w Z|wc -l)
  echo -e "\n  Details of each zombie processes found   "
  echo -e "  $D"
  ZPROC=$(ps -eo stat,pid|grep -w Z|awk '{print $2}')
  for i in $(echo -e "$ZPROC"); do
      ps -o pid,ppid,user,stat,args -p $i
  done
else
 echo -e "No zombie processes found on the system."
fi
#--------Check Inode usage--------#
echo -e "\n\n<strong>INode Usage</strong>"
echo -e "$D$D"
echo -e "( 0-90% = OK/HEALTHY, 90-95% = WARNING, 95-100% = CRITICAL )"
echo -e "$D$D"
# echo -e "<strong>INode Utilization (Percentage Used):</strong>\n"

COL11=$(echo -e "$IUSAGE"|awk '{print $1" "$7}')
COL22=$(echo -e "$IUSAGE"|awk '{print $6}'|sed -e 's/%//g')

for i in $(echo -e "$COL22"); do
{
  if [[ $i = *[[:digit:]]* ]]; then
  {
  if [ $i -ge 95 ]; then
    COLOR=ff0000
    COL33="$(echo -e $i"% $CCOLOR\n$COL33")"
  elif [[ $i -ge 90 && $i -lt 95 ]]; then
    COLOR=ffff00
    COL33="$(echo -e $i"% $WCOLOR\n$COL33")"
  else
    COLOR=add8e6
    COL33="$(echo -e $i"% $GCOLOR\n$COL33")"
  fi
  }
  else
    COL33="$(echo -e $i"% (Inode Percentage details not available)\n$COL33")"
  fi
}
done

COL33=$(echo -e "$COL33"|sort -k1n)
paste  <(echo -e "$COL11") <(echo -e "$COL33") -d' '|column -t

#--------Check for SWAP Utilization--------#
echo -e "\n\nChecking SWAP Details"
echo -e "$D"
echo -e "Total Swap Memory in MiB : "$(grep -w SwapTotal /proc/meminfo|awk '{print $2/1024}')", in GiB : "\
$(grep -w SwapTotal /proc/meminfo|awk '{print $2/1024/1024}')
echo -e "Swap Free Memory in MiB : "$(grep -w SwapFree /proc/meminfo|awk '{print $2/1024}')", in GiB : "\
$(grep -w SwapFree /proc/meminfo|awk '{print $2/1024/1024}')

#--------Check for Processor Utilization (current data)--------#
echo -e "\n\n<strong>Checking For Processor Utilization</strong>"
echo -e "$D"
# echo -e "\nCurrent Processor Utilization Summary :\n"
# mpstat|tail -2
ps -A -o %cpu | awk '{s+=$1} END {print s "%"}'

#--------Check for load average (current data)--------#
echo -e "\n\n<strong>Checking For Load Average</strong>"
echo -e "$D"
echo -e "Current Load Average : $(uptime|grep -o "load average.*"|awk '{print $3" " $4" " $5}')"

#------Print most recent 3 reboot events if available----#
echo -e "\n\nMost Recent 3 Reboot Events"
echo -e "$D$D"
last -x 2> /dev/null|grep reboot 1> /dev/null && /usr/bin/last -x 2> /dev/null|grep reboot|head -3 || \
echo -e "No reboot events are recorded."

#------Print most recent 3 shutdown events if available-----#
echo -e "\n\nMost Recent 3 Shutdown Events"
echo -e "$D$D"
last -x 2> /dev/null|grep shutdown 1> /dev/null && /usr/bin/last -x 2> /dev/null|grep shutdown|head -3 || \
echo -e "No shutdown events are recorded."

#Check current ssh sessions
echo -e "\n\nActive User Sessions"
echo -e "$D$D"
w
#

#--------Print top 5 most memory consuming resources---------#
echo -e "\n\n<strong>Top 5 Memory Resource Hog Processes</strong>"
echo -e "$D$D"
# ps -eo pmem,pcpu,pid,ppid,user,stat,args | sort -k 1 -r | head -6|sed 's/$/\n/'
ps -eo pmem,pcpu,pid,ppid,user,stat,comm | sort -k 1 -r | head -6|sed 's/$/\n/'

#--------Print top 5 most CPU consuming resources---------#
echo -e "\n\n<strong>Top 5 CPU Resource Hog Processes</strong>"
echo -e "$D$D"
# ps -eo pcpu,pmem,pid,ppid,user,stat,args | sort -k 1 -r | head -6|sed 's/$/\n/'
ps -eo pcpu,pmem,pid,ppid,user,stat,comm | sort -k 1 -r | head -6|sed 's/$/\n/'
}

checkstatus > $LOGFILE
sleep 0.5
message=$(cat $LOGFILE | sed ':a;N;$!ba;s/\n/<br>/g'  | sed 's/"/\"/g' | sed "s/'/\'/g")

function sendalert {
    if [ $alertstatus == "TRUE" ]; then
        MESSAGE=$(echo $message | sed 's/"/\"/g' | sed "s/'/\'/g" )
        # ip=$(curl -k https://ifconfig.info)
        TITLE="$(hostname):- $(curl -sk https://ifconfig.info)"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
        # echo $JSON
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
    else
        return 1
    fi
}

sendalert "$message"
sudo rm "$LOGFILE"
