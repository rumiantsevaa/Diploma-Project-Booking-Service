document.addEventListener('DOMContentLoaded', () => {
    initializeEventListeners();
});

function initializeEventListeners() {
    // Делегирование событий для кнопок бронирования
    document.querySelector('.hotel-grid').addEventListener('click', (e) => {
        if (e.target.classList.contains('book-btn')) {
            const hotelId = e.target.dataset.hotelId;
            const hotelName = e.target.dataset.hotelName;
            showBookingForm(hotelId, hotelName);
        }
    });

    // Кнопки формы бронирования
    document.getElementById('submitButton').addEventListener('click', submitBooking);
    document.getElementById('returnButton').addEventListener('click', showHotelList);
}

function showBookingForm(hotelId, hotelName) {
    document.getElementById('hotelList').classList.add('hidden');
    document.getElementById('bookingForm').classList.remove('hidden');
    document.getElementById('hotelNameBooking').textContent = hotelName;
    document.getElementById('hotelId').value = hotelId;
    document.getElementById('errorMessage').textContent = '';
}

function showHotelList() {
    document.getElementById('hotelList').classList.remove('hidden');
    document.getElementById('bookingForm').classList.add('hidden');
    document.getElementById('errorMessage').textContent = '';
    // Очистка формы
    document.getElementById('bookForm').reset();
}

async function submitBooking() {
    const hotelId = document.getElementById('hotelId').value;
    const name = document.getElementById('name').value;
    const phone = document.getElementById('phone').value;
    const errorMessage = document.getElementById('errorMessage');

    try {
        const response = await fetch(`/book/${hotelId}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `name=${encodeURIComponent(name)}&phone=${encodeURIComponent(phone)}`
        });

        const data = await response.json();

        if (data.error) {
            errorMessage.textContent = data.error;
        } else {
            alert('Booking successful!');
            showHotelList();
        }
    } catch (error) {
        errorMessage.textContent = 'An error occurred. Please try again.';
        console.error('Booking error:', error);
    }
}
