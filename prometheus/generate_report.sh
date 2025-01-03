#!/bin/bash

REPORTS_DIR="/prometheus/reports"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${REPORTS_DIR}/server_status_${DATE}.txt"

# Create report header
echo "Server Status Report - ${DATE}" > $REPORT_FILE
echo "------------------------" >> $REPORT_FILE

# Try to get metrics from Prometheus
if ! CPU_USAGE=$(curl -s "http://localhost:9090/api/v1/query?query=node:cpu_usage:rate5m" | jq -r '.data.result[0].value[1]' 2>/dev/null); then
    echo "Error: Prometheus is not accessible" >> $REPORT_FILE
    exit 1
fi

# Format and add CPU usage to report
awk -v cpu="$CPU_USAGE" 'BEGIN {printf "CPU Usage: %.2f%%\n", cpu}' >> $REPORT_FILE

# Get disk space metrics
DISK_FREE=$(curl -s "http://localhost:9090/api/v1/query?query=node:disk_free:percent" | jq -r '.data.result[0].value[1]')
awk -v disk="$DISK_FREE" 'BEGIN {printf "Free Disk Space: %.2f%%\n", disk}' >> $REPORT_FILE

# Cleanup old reports (older than 7 days)
find $REPORTS_DIR -name "server_status_*.txt" -mtime +7 -delete
