#!/bin/bash

# Установка python и pip если не установлены
sudo apt-get update
sudo apt-get install -y python3 python3-pip

# Установка yagmail
pip3 install yagmail

# Создаем скрипт для отправки уведомлений
cat > /usr/lib/netdata/python.d/alert_notify.py << EOF
import yagmail

def send_alert(subject, message):
    try:
        yag = yagmail.SMTP("${ALERT_NETDATA_EMAIL}", "${ALERT_NETDATA_PASS}")
        yag.send(
            to="${ALERT_NETDATA_EMAIL}",
            subject=subject,
            contents=message
        )
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 2:
        send_alert(sys.argv[1], sys.argv[2])
EOF

# Делаем скрипт исполняемым
chmod +x /usr/lib/netdata/python.d/alert_notify.py

# Настраиваем конфигурацию алертов
cat > /etc/netdata/health.d/ram.conf << EOF
alarm: ram_usage_80
    on: system.ram
    lookup: average -1m percentage of used
    units: %
    every: 1m
    warn: \$this > 80
    crit: \$this > 90
    info: RAM usage is above 80%
    exec: /usr/bin/python3 /usr/lib/netdata/python.d/alert_notify.py "High RAM Usage Alert" "RAM usage is at \$this%"
EOF

cat > /etc/netdata/health.d/cpu.conf << EOF
alarm: cpu_usage_80
    on: system.cpu
    lookup: average -1m percentage of user
    units: %
    every: 1m
    warn: \$this > 80
    crit: \$this > 90
    info: CPU usage is above 80%
    exec: /usr/bin/python3 /usr/lib/netdata/python.d/alert_notify.py "High CPU Usage Alert" "CPU usage is at \$this%"
EOF

cat > /etc/netdata/health.d/docker.conf << EOF
alarm: docker_container_unhealthy
    on: docker.container_health
    lookup: min -1m unaligned of health
    units: status
    every: 1m
    warn: \$this != 1
    crit: \$this == 0
    info: Docker container is not healthy
    exec: /usr/bin/python3 /usr/lib/netdata/python.d/alert_notify.py "Docker Container Alert" "Container health status is \$this"
EOF