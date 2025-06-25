#!/bin/bash

LOGFILE="/var/log/pingloop.log"

MEM=""

while true; do
	echo "$(date): pinging 8.8.8.8..." >> "$LOGFILE"
	MEM="$MEM $(head -c 5M /dev/urandom | base64)"
	ping -c 1 8.8.8.8 >> "$LOGFILE" 2>&1
	sleep 5
done

