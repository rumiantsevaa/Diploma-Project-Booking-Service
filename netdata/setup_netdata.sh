#!/bin/bash

# Проверяем установлен ли Netdata
if ! command -v netdata &> /dev/null; then
    echo "Installing Netdata..."
    wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
    
    # Копируем конфигурацию
    cp ./netdata/netdata.conf /etc/netdata/netdata.conf
else
    echo "Netdata already installed"
fi

# Настраиваем cron задачу
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRON_CMD="$SCRIPT_DIR/save_dashboard.sh"

if ! sudo crontab -l | grep -q "$CRON_CMD"; then
    (sudo crontab -l 2>/dev/null; echo "0 * * * * $CRON_CMD") | sudo crontab -
    echo "Cron job added"
fi
