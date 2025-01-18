// static/js/scripts.js
document.addEventListener('DOMContentLoaded', function() {
    // Handle booking button clicks
    document.querySelectorAll('.book-btn').forEach(button => {
        button.addEventListener('click', function() {
            const hotelId = this.dataset.hotelId;
            const hotelName = this.dataset.hotelName;
            
            document.getElementById('hotelList').classList.add('hidden');
            document.getElementById('bookingForm').classList.remove('hidden');
            document.getElementById('hotelId').value = hotelId;
            
            // Use TrustedDOMHandler for safe DOM manipulation
            TrustedDOMHandler.updateBookingForm(hotelName);
        });
    });

    // Handle form submission
    document.getElementById('submitButton').addEventListener('click', function() {
        const form = document.getElementById('bookForm');
        const formData = new FormData(form);
        
        fetch(`/book/${formData.get('hotel_id')}`, {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                TrustedDOMHandler.showError(data.error);
            } else {
                TrustedDOMHandler.showError('Booking successful!');
                form.reset();
            }
        })
        .catch(error => {
            TrustedDOMHandler.showError('An error occurred during booking.');
        });
    });

    // Add return button functionality
    document.getElementById('returnButton').addEventListener('click', function() {
        document.getElementById('bookingForm').classList.add('hidden');
        document.getElementById('hotelList').classList.remove('hidden');
        TrustedDOMHandler.showError(''); // Clear any error messages
    });
});