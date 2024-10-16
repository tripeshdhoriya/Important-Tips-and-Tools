#!/bin/bash

time=$(date +%d%m%y_%H%M)
db=bc_rtv
export PGPASSWORD='BCRTV#1'
user="rtv"
role=rtv
host=127.0.0.1
pg_dump --host $host --port 5432 --username "$user" --role "$role" --verbose --format=c --blobs --section=pre-data --section=data --section=post-data --file "$db.$time.dump" "$db"
#sslmode=require
if [ $? -eq 0 ]; then
	zip $db.$time.zip $db.$time.dump
	rm ./*.dump
fi
find /home/sigmastream/dbbackup/Bluecardinal/ -mindepth 1 -name '*.zip' -mtime +5 -delete -print

