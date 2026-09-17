#!/bin/bash

# Report File
REPORT_FILE="reports/log_report_$(date +%Y-%m-%d_%H-%M-%S).txt"

# Save output to terminal and report file
exec > >(tee -a "$REPORT_FILE") 2>&1

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

# Failed Login Attempts by IP
echo "Failed Login Atempts by IP:"
awk '/Failed password/ {print $11}' "$LOG_FILE" | sort | uniq -c | sort -nr

# Successful Login Attempts
SUCCESSFUL_LOGINS=$(grep -c "Accepted password" "$LOG_FILE")
echo "Successful Login Attempts: $SUCCESSFUL_LOGINS"

# Suspicious IP Alert
echo "Suspicious IP Addresses:"
awk '/Failed password/ {print $11}' "$LOG_FILE" | sort | uniq -c | sort -nr | while read COUNT IP
do
	if [ "$COUNT" -ge 2 ]; then
		echo "WARNING: $IP has $COUNT failed login attempts!"
	fi
done

# Error and Warning Analysis
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")

echo "Application Errors: $ERROR_COUNT"
echo "Application Warnings: $WARNING_COUNT"

echo "Log Level Summary"
INFO_COUNT=$(grep -c "INFO" "$LOG_INFO")
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")

echo "INFO Messages: $INFO_COUNT"

echo "======================================================="
