#!/bin/bash

echo "==============================="
echo " LINUX LOG ANALYZER AND SECURITY MONITOR"
echo "==============================="

echo "Hostname : $(hostname)"
echo "Date     : $(date)"


echo "======================================================"

# Log Files
#LOG_FILE="/var/log/auth.log"
LOG_FILE="logs/sample_auth.log"

echo "Analyzing Log Files: $LOG_FILE"

# Check if log file exists
if [ -f "$LOG_FILE" ]; then
	echo "Log file found successfully."
else
	echo "ERROR: Log file not found!"
	exit 1
fi

# Total Log Entries
TOTAL_LOGS=$(wc -l < "$LOG_FILE")

echo "Total Log Entries: $TOTAL_LOGS"

# Failed Login Attempts
FAILED_LOGIN=$(grep -c "Failed password" "$LOG_FILE")
echo "Failed Login Attempts: $FAILED_LOGIN"

echo "======================================================"


