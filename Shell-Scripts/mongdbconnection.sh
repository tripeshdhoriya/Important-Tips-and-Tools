#!/bin/bash

# Store the connection string in a variable
conn_string="mongodb://host:port/database"

# Use the mongo shell to check the connection
mongo "$conn_string" --eval "printjson(db.runCommand({ ping: 1 }))"

# Check the exit status of the mongo shell command
if [ $? -eq 0 ]; then
  echo "Successful connection to MongoDB"
else
  echo "Failed to connect to MongoDB"
fi