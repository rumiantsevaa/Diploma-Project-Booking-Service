const bookBtns = document.querySelectorAll(".book-btn");
bookBtns.forEach((btn) => {
    btn.addEventListener("click", (event) => {
        const hotelId = event.currentTarget.dataset.hotelId;
        const hotelName = event.currentTarget.dataset.hotelName;
        if (!window.bookFormDialog) {
            const bookFormTemplate = document.getElementById("booking-form-template");
            const bookingForm = bookFormTemplate.content.cloneNode(true);
            document.body.appendChild(bookingForm);
            window.bookFormDialog = document.getElementById("booking-form-dialog");
        }

        window.bookFormDialog.showModal();
        const form = window.bookFormDialog.querySelector("#book-form");
        form.addEventListener("submit", book);
        window.bookFormDialog.querySelector('slot[name="hotel-name"]').textContent = hotelName;
        window.bookFormDialog.querySelector('#hotel-id').value = hotelId;
    });
});

async function book(event) {
    event.preventDefault();

    const form = event.target;
    const url = form.action;
    const formData = new FormData(form);
    const response = await fetch(url, {
        method: "POST",
        body: formData,
    });

    const result = await response.json();
    console.log(result);
}