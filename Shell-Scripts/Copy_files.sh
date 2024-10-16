#!/bin/bash

# Step 1: Stop the server
echo "Stopping yhserver server..."
ssh sigmastream@192.168.2.105 'sudo systemctl stop yhserver'

# Step 2: Rename ROOT.war file
echo "Renaming ROOT.war file..."
ssh sigmastream@192.168.2.105 'sudo mv /path/to/server/ROOT.war /path/to/server/OLD_ROOT.war'

# Step 3: Copy ROOT.war file from Jenkins server
echo "Copying ROOT.war file from Jenkins server..."
scp -r /home/Jenkins-Build-Files/YellowHammer/2023/07-03/13:48-16322-Standardization-Subscription/yellowhammer-server/ROOT.war sigmastream@192.168.2.105:/home/sigmastream/yellowhammer/yellowhammer-server/yellowhammer-base/webapps/

# Step 4: Touch ROOT.war file
echo "Touching ROOT.war file..."
ssh sigmastream@192.168.2.105 'sudo touch /home/sigmastream/yellowhammer/yellowhammer-server/yellowhammer-base/webapps/ROOT.war'

# Step 5: Remove logs
echo "Removing logs..."
ssh sigmastream@192.168.2.105 'sudo rm -rf /home/sigmastream/yellowhammer/yellowhammer-server/yellowhammer-base/logs/*'

# Step 6: Start the server
echo "Starting server..."
ssh sigmastream@192.168.2.105 'sudo systemctl start yhserver'

echo "Server deployment completed successfully."