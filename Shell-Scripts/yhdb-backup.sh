#!/bin/bash

time=$(date +%d%m%y_%H%M)
db=yellowhammer
export PGPASSWORD='SigmaStream#1'
user="sigmastream"
role=sigmastream
host=10.0.0.5
pg_dump --host $host --port 5432 --username "$user" --role "$role" --verbose --file "$db.$time.dmp" "$db"
#sslmode=require
if [ $? -eq 0 ]; then
	zip $db.$time.zip $db.$time.dmp
	rm ./*.dmp
fi
find /apps/Tools/Backup/YellowHammer/ -mindepth 1 -name '*.zip' -mtime +7 -delete -print
