import sqlite3

# Создание базы данных и заполнение отелями
conn = sqlite3.connect('hotels.db')
cursor = conn.cursor()

# Создание таблиц
cursor.execute('''
CREATE TABLE IF NOT EXISTS hotels (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    price_per_night REAL NOT NULL,
    description TEXT
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

# В init_db.py добавим путь к картинкам
cursor.execute('PRAGMA table_info(hotels)')
columns = [col[1] for col in cursor.fetchall()]
if 'image_path' not in columns:
    cursor.execute('ALTER TABLE hotels ADD COLUMN image_path TEXT')
hotels = [
    ('Cozy Cottage in the Carpathians', 'Romania, Carpathian Mountains', 50.00, 'Small wooden house among the Carpathian forests', 'carpathian_cottage.jpg'),
    ('Romantic Cottage', 'Romania, Carpathian Foothills', 65.00, 'Charming house with mountain landscape views', 'romantic_cottage.jpg'),
    ('Treehouse', 'Norway, Fjords', 120.00, 'Unique hotel among Norwegian pines with panoramic view', 'treehouse.jpg')
]

cursor.executemany('''
INSERT INTO hotels (name, location, price_per_night, description, image_path) 
VALUES (?, ?, ?, ?, ?)
''', hotels)

# Сохранение изменений
conn.commit()
conn.close()

print("База данных инициализирована с тремя отелями.")
