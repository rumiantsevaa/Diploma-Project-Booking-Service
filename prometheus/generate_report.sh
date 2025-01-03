#!/bin/bash

REPORTS_DIR="/prometheus/reports"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORTS_DIR/server_status_${DATE}.txt"

# Создаем отчет
echo "Server Status Report - ${DATE}" > $REPORT_FILE
echo "------------------------" >> $REPORT_FILE

# CPU Usage
curl -s "http://localhost:9090/api/v1/query?query=node:cpu_usage:rate5m" | \
jq -r '.data.result[0].value[1]' | \
awk '{printf "CPU Usage: %.2f%%\n", $1}' >> $REPORT_FILE

# Disk Space
curl -s "http://localhost:9090/api/v1/query?query=node:disk_free:percent" | \
jq -r '.data.result[0].value[1]' | \
awk '{printf "Free Disk Space: %.2f%%\n", $1}' >> $REPORT_FILE

# Удаляем старые отчеты (оставляем только за последние 7 дней)
find $REPORTS_DIR -name "server_status_*.txt" -mtime +7 -delete