# Базовый образ Python
FROM python:3.10-slim

# Устанавливаем зависимости
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем проект в контейнер
COPY . .

# Указываем порт Flask
EXPOSE 443

# Скрипт для запуска init_db.py и app.py
CMD ["bash", "-c", "python init_db.py && python app.py"]
