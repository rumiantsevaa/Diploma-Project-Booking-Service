#!/bin/bash

# Переменные
CRON_JOB="0 3 1 * * certbot renew --quiet"

# Проверка прав администратора
if [[ $EUID -ne 0 ]]; then
  echo "Пожалуйста, запустите скрипт с правами администратора (sudo)." >&2
  exit 1
fi

echo "=== Управление Certbot и сертификатами ==="

# Проверка установленного Certbot
if ! certbot --version &>/dev/null; then
  echo "Certbot не установлен. Устанавливаем Certbot..."
  apt update
  apt install -y certbot
else
  echo "Certbot установлен. Версия: $(certbot --version)"
fi

# Проверка сертификатов
CERT_STATUS=$(sudo certbot certificates | grep -E "Domains: www.bbooking.pp.ua|Domains: bbooking.pp.ua" || echo "not found")

if [[ "$CERT_STATUS" == "not found" ]]; then
  echo "Сертификаты для доменов www.bbooking.pp.ua и bbooking.pp.ua отсутствуют. Выпускаем новые..."
  certbot certonly --standalone -d www.bbooking.pp.ua -d bbooking.pp.ua --email "${{ secrets.EMAIL_FOR_CERTBOT }}" --agree-tos --non-interactive
else
  echo "Сертификаты найдены. Проверяем срок действия..."
  EXPIRY_DATE=$(certbot certificates | grep -A 1 "Domains: www.bbooking.pp.ua" | grep "Expiry Date" | awk '{print $3, $4, $5}')
  EXPIRY_DAYS=$(($(date -d "$EXPIRY_DATE" +%s) - $(date +%s)))
  EXPIRY_DAYS=$((EXPIRY_DAYS / 86400))

  if [[ $EXPIRY_DAYS -le 0 ]]; then
    echo "Сертификат истёк. Перевыпускаем..."
    certbot renew --force-renewal
  else
    echo "Сертификат действителен ещё $EXPIRY_DAYS дней."
  fi
fi

# Проверка наличия задачи в crontab
if crontab -l | grep -Fq "certbot renew"; then
  echo "Задача обновления сертификатов уже настроена."
else
  echo "Задача обновления сертификатов не найдена. Добавляем в crontab..."
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "Задача добавлена: $CRON_JOB"
fi

echo "Управление Certbot завершено."
