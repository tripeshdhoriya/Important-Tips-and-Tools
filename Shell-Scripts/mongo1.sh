#!/bin/bash
# shell script to setup mongodb 3.6.9 with data direcory setup in ubuntu

      

           echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list

           echo "---------- updating server’s local package index --------------"

           sudo apt update -y

           echo "----------- installing MongoDB packages --------------"

                sudo apt install mongodb-org-server=3.6.9 -y
                sudo apt install mongodb-org-shell=3.6.9 -y 
                sudo apt install mongodb-org-mongos=3.6.9 -y
                sudo apt install mongodb-org-tools=3.6.9 -y

         
               echo "--------- start/enable the updated systemd service for your MongoDB instance -------------"

                sudo systemctl start mongod
                sudo systemctl enable mongod
                echo
                echo "---------------------- mongodb installation completed ------------------------ "

  echo
  echo "-----Completed--------"

