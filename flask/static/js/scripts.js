    <script>
        function showBookingForm(hotelId, hotelName) {
            document.getElementById('hotelList').style.display = 'none';
            document.getElementById('bookingForm').style.display = 'block';
            document.getElementById('hotelNameBooking').textContent = hotelName;
            document.getElementById('hotelId').value = hotelId;
        }

        function showHotelList() {
            document.getElementById('hotelList').style.display = 'block';
            document.getElementById('bookingForm').style.display = 'none';
            document.getElementById('errorMessage').textContent = '';
        }

        function submitBooking() {
            const name = document.getElementById('name').value;
            const phone = document.getElementById('phone').value;
            const hotelId = document.getElementById('hotelId').value;

            const phonePattern = /^380\d{9}$/;
            if (!phonePattern.test(phone)) {
                document.getElementById('errorMessage').textContent = 'Enter correct phone number(ua country code with no + sign) 380XXXXXXXXX';
                return;
            }

            fetch(`/book/${hotelId}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `name=${encodeURIComponent(name)}&phone=${encodeURIComponent(phone)}`
            })
            .then(response => {
                if (response.ok) {
                    alert('Successfully Booked! Our manager will call you back in no time.');
                    showHotelList();
                } else {
                    throw new Error('Booking error');
                }
            })
            .catch(error => {
                document.getElementById('errorMessage').textContent = 'Booking error. Try again later.';
            });
        }
    </script>