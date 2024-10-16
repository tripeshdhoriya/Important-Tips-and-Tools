#!/bin/bash
threshold=$1
hostName=$2
uom=$3
if [ "${uom}" = "F" ]; then  
	 usage=`snmpget -v1 -c ConocoMGMT -OQUv ${hostName} .1.3.6.1.4.1.318.1.1.25.1.2.1.5.1.1`
else
	 usage=`snmpget -v1 -c ConocoMGMT -OQUv ${hostName} .1.3.6.1.4.1.318.1.1.25.1.2.1.6.1.1`
fi
        
if [ "${usage}" -gt "${threshold}" ]; then
		echo "FAIL:$usage"
else
		echo "SUCCESS:$usage"
fi
