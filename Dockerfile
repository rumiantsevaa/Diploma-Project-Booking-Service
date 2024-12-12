# Используем официальный образ Nginx
FROM nginx:latest

# Открываем порт 80 для HTTP
EXPOSE 80

# Старт Nginx
CMD ["nginx", "-g", "daemon off;"]
