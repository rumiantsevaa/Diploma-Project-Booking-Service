from flask import Flask, render_template, request, jsonify
import sqlite3
import re
import os

app = Flask(__name__)

def get_db_connection():
    conn = sqlite3.connect('hotels.db')
    conn.row_factory = sqlite3.Row
    return conn

def validate_phone_number(phone):
    pattern = r'^380\d{9}$'
    return re.match(pattern, phone) is not None

@app.route('/')
def index():
    conn = get_db_connection()
    hotels = conn.execute('SELECT * FROM hotels').fetchall()
    conn.close()
    return render_template('index.html', hotels=hotels)

@app.route('/book/<int:hotel_id>', methods=['POST'])
def book_hotel(hotel_id):
    conn = get_db_connection()
    
    name = request.form['name']
    phone = request.form['phone']
    
    if not validate_phone_number(phone):
        return jsonify({"error": "Incorrect phone number"}), 400
    
    conn.execute('INSERT INTO bookings (hotel_id, client_name, client_phone) VALUES (?, ?, ?)',
                 (hotel_id, name, phone))
    conn.commit()
    conn.close()
    return jsonify({"message": "Successfully Booked"}), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
