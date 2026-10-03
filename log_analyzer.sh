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

# Help option
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Linux Log Analyzer and Security Monitor"
	echo
	echo "Usage:"
	echo "  ./log_analyzer.sh [LOG_FILE]"
	echo 
	echo "Examples:"
	echo "  ./log_analyzer.sh"
	echo "  ./log_analyzer.sh logs/sample_auth.log"
	echo "  ./log_analyzer.sh /var/log/auth.log"
	exit 0
fi

# Log Files
#LOG_FILE="/var/log/auth.log"
LOG_FILE="${1:-logs/sample_auth.log}"

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

# Failed Login Attempts by user
echo "Failed Login Attempts by User:"
awk '/Failed password/ {print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr

# Failed Login Attempts by Hour
echo "Failed Login Attempts by Hour:"
awk '/Failed password/ {print $3}' "$LOG_FILE" | sort | uniq -c | sort -nr

# Successful Login Attempts
SUCCESSFUL_LOGINS=$(grep -c "Accepted password" "$LOG_FILE")
echo "Successful Login Attempts: $SUCCESSFUL_LOGINS"

# Suspicious user alert
echo "Suspicious Users:"
awk '/Failed password/ {print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | while read COUNT USER
do
	if [ "$COUNT" -ge 2 ]; then
		echo "WARNING: User $USER has $COUNT failed login attempts!"
	fi
done

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
INFO_COUNT=$(grep -c "INFO" "$LOG_FILE")
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")

echo "INFO Messages: $INFO_COUNT"
echo "ERROR Messages: $ERROR_COUNT"
echo "WARNING Messages: $WARNING_COUNT"

# Error Messages
echo "Error Messages:"
grep "ERROR" "$LOG_FILE"

echo "======================================================="

# Warning Messages
echo "Warning Messages:"
grep "WARNING" "$LOG_FILE"

# Recent Log Activity
echo "Recent Log Activity:"
tail -n 5 "$LOG_FILE"

# Latest Log Entry
echo "Latest Log Entry:"
tail -n 1 "$LOG_FILE"

# Most Common Log Messages
echo "Most Common Log Messages:"

awk '{for (i=5; i<=NF; i++) printf "%s ", $i; print ""}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5

echo "======================================================="
