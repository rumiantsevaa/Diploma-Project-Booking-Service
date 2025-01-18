// static/js/scripts.js
document.addEventListener('DOMContentLoaded', function() {
    const policy = trustedTypes.defaultPolicy || trustedTypes.policies.get('bookingPolicy');

    // Safe DOM manipulation function
    function setInnerHTML(element, content) {
        if (element && content) {
            element.innerHTML = policy.createHTML(content);
        }
    }

    // Handle booking button clicks
    document.querySelectorAll('.book-btn').forEach(button => {
        button.addEventListener('click', function() {
            const hotelId = this.dataset.hotelId;
            const hotelName = this.dataset.hotelName;
            
            document.getElementById('hotelList').classList.add('hidden');
            document.getElementById('bookingForm').classList.remove('hidden');
            document.getElementById('hotelId').value = hotelId;
            
            // Use safe DOM manipulation
            const hotelNameElement = document.getElementById('hotelNameBooking');
            setInnerHTML(hotelNameElement, hotelName);
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
            const errorElement = document.getElementById('errorMessage');
            if (data.error) {
                setInnerHTML(errorElement, data.error);
            } else {
                setInnerHTML(errorElement, 'Booking successful!');
                form.reset();
            }
        })
        .catch(error => {
            const errorElement = document.getElementById('errorMessage');
            setInnerHTML(errorElement, 'An error occurred during booking.');
        });
    });

    // Add return button functionality
    document.getElementById('returnButton').addEventListener('click', function() {
        document.getElementById('bookingForm').classList.add('hidden');
        document.getElementById('hotelList').classList.remove('hidden');
        // Clear any error messages
        const errorElement = document.getElementById('errorMessage');
        setInnerHTML(errorElement, '');
    });
});