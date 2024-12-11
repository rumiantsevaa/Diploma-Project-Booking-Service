# Базовый образ Python
FROM python:3.10-slim

# Устанавливаем зависимости
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем проект в контейнер
COPY . .

# Устанавливаем Nginx
RUN apt-get update && apt-get install -y nginx

# Копируем конфигурацию Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Указываем порты для Flask и Nginx
EXPOSE 5000
EXPOSE 443

# Запускаем сначала init_db.py, затем app.py
CMD python init_db.py && service nginx start && python app.py
