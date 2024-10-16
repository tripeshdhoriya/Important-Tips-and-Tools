#!/bin/bash

# shell script that check if user is created or not, if already created then print message, otherwise it will create user according to user input.
echo "------ create user--------"

user_name="namita"
#echo "Enter username:"
#read user_name
chk_user=$(sudo cat /etc/passwd | cut -d ":" -f 1 | grep $user_name)


if [[ $user_name == $chk_user ]]
then
        echo "$user_name is already created"
else
 sudo useradd $user_name -s /bin/bash -d /home/$user_name -m
 cat /etc/passwd | grep $user_name

echo "$user_name:$user_name" | sudo chpasswd

fi

