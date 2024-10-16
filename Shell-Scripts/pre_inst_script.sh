#!/bin/bash
# check if package is already exist or not

if [ -f /usr/bin/java ]
then
    echo "Java is already installed "

else 
echo "------------------Installing java-----------------"
sudo apt install openjdk-11-jdk -y
fi

if [ -f /usr/bin/telnet ]
then
    echo "Telnet exist"
else
echo "------------Installing Telnet--------------"  
sudo apt install telnetd -y 
fi

if [ -f /usr/bin/netstat ]
then 
echo "net-tools is already installed"
else
echo "-------------Installing net-tools--------------"
sudo apt install net-tools -y 
fi
if [ -f /usr/bin/expect  ]
Then
echo "ecpect is already installed"
else
echo "-----------Installing expect----------------- "
sudo apt install expect -y


