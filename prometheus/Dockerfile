FROM prom/prometheus:latest

# Копируем конфигурационные файлы
COPY --chown=nobody:nobody prometheus.yml /etc/prometheus/prometheus.yml
COPY --chown=nobody:nobody rules/ /etc/prometheus/rules/

# Создаем директорию для отчетов и даем права
RUN mkdir -p /prometheus/reports && \
    chown -R nobody:nobody /prometheus/reports && \
    chmod -R 755 /prometheus/reports

# Копируем скрипт генерации отчетов
COPY --chown=nobody:nobody generate_report.sh /prometheus/generate_report.sh
RUN chmod +x /prometheus/generate_report.sh

USER nobody

EXPOSE 9090

ENTRYPOINT [ "/bin/prometheus" ]
CMD [ "--config.file=/etc/prometheus/prometheus.yml", \
      "--storage.tsdb.path=/prometheus", \
      "--web.enable-lifecycle" ]