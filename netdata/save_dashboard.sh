# /netdata/save_dashboard.sh
#!/bin/bash
OUTPUT_DIR="/var/log/netdata/dashboards"
GITHUB_DIR="/project/netdata/dashboards"
mkdir -p $OUTPUT_DIR
mkdir -p $GITHUB_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
curl -o "${OUTPUT_DIR}/netdata_${TIMESTAMP}.html" http://127.0.0.1:19999
cp "${OUTPUT_DIR}/netdata_${TIMESTAMP}.html" "${GITHUB_DIR}/latest_dashboard.html"
