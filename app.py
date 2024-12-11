from flask import Flask, render_template, request, jsonify
import sqlite3
import re

app = Flask(__name__)

# Подключение к базе данных
def get_db_connection():
    conn = sqlite3.connect('/app/data/hotels.db')  # Пусть база хранится внутри контейнера
    conn.row_factory = sqlite3.Row
    return conn

# Проверка корректности номера телефона
def validate_phone_number(phone):
    pattern = r'^380\d{9}$'
    return re.match(pattern, phone) is not None

# Главная страница
@app.route('/')
def index():
    conn = get_db_connection()
    hotels = conn.execute('SELECT * FROM hotels').fetchall()
    conn.close()
    return render_template('index.html', hotels=hotels)

# Бронирование отеля
@app.route('/book/<int:hotel_id>', methods=['POST'])
def book_hotel(hotel_id):
    conn = get_db_connection()
    name = request.form.get('name')
    phone = request.form.get('phone')
    
    if not name or not phone:
        return jsonify({"error": "Name and phone are required"}), 400
    
    if not validate_phone_number(phone):
        return jsonify({"error": "Invalid phone number"}), 400
    
    conn.execute('INSERT INTO bookings (hotel_id, client_name, client_phone) VALUES (?, ?, ?)',
                 (hotel_id, name, phone))
    conn.commit()
    conn.close()
    return jsonify({"message": "Booking successful"}), 200

if __name__ == '__main__':
    # Flask-приложение будет слушать на порту 8000
    app.run(host='0.0.0.0', port=8000, debug=False)
