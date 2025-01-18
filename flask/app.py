import re
import secrets
import sqlite3

from flask import Flask, render_template, request, jsonify
from flask import g

# Создание или подключение к базе данных <== MERGED FROM INIT_DB.PY  
db_path = 'hotels.db'
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Создание таблиц <== MERGED FROM INIT_DB.PY  
cursor.execute('''
CREATE TABLE IF NOT EXISTS hotels (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    location TEXT NOT NULL,
    price_per_night REAL NOT NULL,
    description TEXT,
    image_path TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY,
    hotel_id INTEGER,
    client_name TEXT NOT NULL,
    client_phone TEXT NOT NULL,
    FOREIGN KEY(hotel_id) REFERENCES hotels(id)
)
''')

# Список отелей для добавления/обновления
hotels = [
    ('Cozy Cottage in the Carpathians', 'Romania, Carpathian Mountains', 50.00, 'Small wooden house among the Carpathian forests', 'carpathian_cottage.avif'),
    ('Romantic Cottage', 'Romania, Carpathian Foothills', 65.00, 'Charming house with mountain landscape views', 'romantic_cottage.avif'),
    ('Treehouse', 'Norway, Fjords', 120.00, 'Unique hotel among Norwegian pines with panoramic view', 'treehouse.avif')
]

# Обработка данных
for hotel in hotels:
    name, location, price_per_night, description, image_path = hotel
    # Проверяем, есть ли уже запись с таким именем
    cursor.execute('SELECT id FROM hotels WHERE name = ?', (name,))
    result = cursor.fetchone()
    if result:
        # Если запись есть, обновляем её
        cursor.execute('''
        UPDATE hotels
        SET location = ?, price_per_night = ?, description = ?, image_path = ?
        WHERE name = ?
        ''', (location, price_per_night, description, image_path, name))
    else:
        # Если записи нет, добавляем новую
        cursor.execute('''
        INSERT INTO hotels (name, location, price_per_night, description, image_path)
        VALUES (?, ?, ?, ?, ?)
        ''', hotel)

# Сохранение изменений
conn.commit()
conn.close()

print("База данных обновлена.")

# END OF LINES MERGED FROM INIT_DB.PY  

app = Flask(__name__)


@app.before_request
def before_request():
    g.csp_nonce = request.headers.get('X-CSP-Nonce', secrets.token_urlsafe(32))

@app.after_request
def add_security_headers(response):
    # Добавляем Cross-Origin заголовки
    response.headers['Cross-Origin-Opener-Policy'] = 'same-origin'
    response.headers['Cross-Origin-Embedder-Policy'] = 'require-corp'
    response.headers['Cross-Origin-Resource-Policy'] = 'same-origin'
    # Сохраняем существующий функционал с CSP
    nonce = getattr(g, 'csp_nonce', '')
    csp = (
        "default-src 'self'; "
        f"script-src 'self' 'nonce-{nonce}'; "
        f"style-src 'self' 'nonce-{nonce}'; "
        "img-src 'self' data: https://bbooking.pp.ua; "
        "frame-ancestors 'none'; "
        "base-uri 'self'; "
        "form-action 'self'; "
        "require-trusted-types-for 'script'; "
    "trusted-types default; "
        "object-src 'none'"
    ).format(nonce=nonce)
    response.headers['Content-Security-Policy'] = csp
    response.headers['Permissions-Policy'] = (
        "accelerometer=(),"
        "autoplay=(),"
        "camera=(),"
        "cross-origin-isolated=(),"
        "display-capture=(),"
        "encrypted-media=(),"
        "fullscreen=(self),"
        "geolocation=(),"
        "gyroscope=(),"
        "keyboard-map=(),"
        "magnetometer=(),"
        "microphone=(),"
        "midi=(),"
        "payment=(),"
        "picture-in-picture=(),"
        "publickey-credentials-get=(),"
        "screen-wake-lock=(),"
        "sync-xhr=(),"
        "usb=(),"
        "web-share=(),"
        "xr-spatial-tracking=(),"
        "clipboard-read=(),"
        "clipboard-write=(),"
        "gamepad=(),"
        "hid=(),"
        "idle-detection=(),"
        "interest-cohort=(),"
        "serial=()"
    )
    return response


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


@app.route('/book/', methods=['POST'])
def book_hotel():
    conn = get_db_connection()

    hotel_id = request.form['hotel-id']
    name = request.form['name']
    phone = request.form['phone']
    
    if not validate_phone_number(phone):
        return jsonify({"error": "Incorrect phone number"}), 400
    
    conn.execute('INSERT INTO bookings (hotel_id, client_name, client_phone) VALUES (?, ?, ?)',
                 (hotel_id, name, phone))
    conn.commit()
    conn.close()
    return jsonify({"message": "Successfully Booked"}), 200


@app.route('/cache-me')
def cache():
    return "nginx will cache this response"

@app.route('/info')
def info():

    resp = {
        'connecting_ip': request.headers['X-Real-IP'],
        'proxy_ip': request.headers['X-Forwarded-For'],
        'host': request.headers['Host'],
        'user-agent': request.headers['User-Agent']
    }

    return jsonify(resp)

@app.route('/flask-health-check')
def flask_health_check():
    return "success"
