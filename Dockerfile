# Базовый образ Python для Flask
FROM python:3.10-slim as python-base

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем проект
COPY . .

# Устанавливаем Gunicorn
RUN pip install gunicorn

# Указываем порт Flask
EXPOSE 8000

# Собираем образ для запуска Flask
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

# ---------

# Базовый образ Nginx
FROM nginx:stable-alpine as nginx-base

# Копируем конфигурацию Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Указываем порт для внешних соединений
EXPOSE 80

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]
