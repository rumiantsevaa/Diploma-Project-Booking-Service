#!/bin/bash

REPORTS_DIR="/var/log/prometheus/reports"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${REPORTS_DIR}/server_status_${DATE}.txt"

# Create reports directory if it doesn't exist
sudo mkdir -p $REPORTS_DIR
sudo chown prometheus:prometheus $REPORTS_DIR

# Create report header
echo "Server Status Report - ${DATE}" > $REPORT_FILE
echo "------------------------" >> $REPORT_FILE

# Get metrics from local Prometheus instance
CPU_USAGE=$(curl -s "http://localhost:9090/api/v1/query?query=100-avg(rate(node_cpu_seconds_total{mode='idle'}[5m]))*100" | jq -r '.data.result[0].value[1]')
DISK_FREE=$(curl -s "http://localhost:9090/api/v1/query?query=node_filesystem_avail_bytes{mountpoint='/'}/node_filesystem_size_bytes{mountpoint='/'} * 100" | jq -r '.data.result[0].value[1]')

# Format and add metrics to report
awk -v cpu="$CPU_USAGE" 'BEGIN {printf "CPU Usage: %.2f%%\n", cpu}' >> $REPORT_FILE
awk -v disk="$DISK_FREE" 'BEGIN {printf "Free Disk Space: %.2f%%\n", disk}' >> $REPORT_FILE

# Cleanup old reports (older than 24 hours)
find $REPORTS_DIR -name "server_status_*.txt" -mtime +1 -delete
