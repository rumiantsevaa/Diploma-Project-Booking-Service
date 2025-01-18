// static/js/trusted-dom.js
class TrustedDOMHandler {
    static policy = trustedTypes.defaultPolicy || trustedTypes.createPolicy('bookingPolicy', {
        createHTML: (string) => string
    });

    static setInnerHTML(element, content) {
        if (element && content) {
            element.innerHTML = this.policy.createHTML(content);
        }
    }

    static updateBookingForm(hotelName) {
        const hotelNameElement = document.getElementById('hotelNameBooking');
        if (hotelNameElement) {
            hotelNameElement.innerHTML = this.policy.createHTML(hotelName);
        }
    }

    static showError(message) {
        const errorElement = document.getElementById('errorMessage');
        if (errorElement) {
            errorElement.innerHTML = this.policy.createHTML(message);
        }
    }
}