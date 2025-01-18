// static/js/trusted-dom.js
class TrustedDOMHandler {
    static policy = (() => {
        // Check if policy already exists
        if (window.trustedTypes?.policies?.get('bookingPolicy')) {
            return window.trustedTypes.policies.get('bookingPolicy');
        }
        
        // Create policy if it doesn't exist
        return window.trustedTypes?.createPolicy('bookingPolicy', {
            createHTML: (string) => {
                const sanitized = string
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#39;');
                return sanitized;
            },
            createScript: (string) => {
                if (string.match(/^(function\s*\(\)\s*\{[\s\S]*\}|\/\/ Booking script)$/)) {
                    return string;
                }
                throw new Error('Invalid script content');
            },
            createScriptURL: (string) => {
                const url = new URL(string, window.location.origin);
                if (url.origin === window.location.origin) {
                    return string;
                }
                throw new Error('Invalid script URL');
            }
        });
    })();

    static setInnerHTML(element, content) {
        if (element && content) {
            element.innerHTML = this.policy.createHTML(content);
        }
    }

    static updateBookingForm(hotelName) {
        const hotelNameElement = document.getElementById('hotelNameBooking');
        if (hotelNameElement) {
            this.setInnerHTML(hotelNameElement, hotelName);
        }
    }

    static showError(message) {
        const errorElement = document.getElementById('errorMessage');
        if (errorElement) {
            this.setInnerHTML(errorElement, message);
        }
    }
}