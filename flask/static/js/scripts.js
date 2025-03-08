const bookBtns = document.querySelectorAll(".book-btn");

bookBtns.forEach((btn) => {
    btn.addEventListener("click", (event) => {
        const hotelId = event.currentTarget.dataset.hotelId;
        const hotelName = event.currentTarget.dataset.hotelName;
        
        // Инициализация диалога
        if (!window.bookFormDialog) {
            const bookFormTemplate = document.getElementById("booking-form-template");
            const bookingForm = bookFormTemplate.content.cloneNode(true);
            document.body.appendChild(bookingForm);
            window.bookFormDialog = document.getElementById("booking-form-dialog");
        }

        // Обновление значений формы
        window.bookFormDialog.showModal();
        const form = window.bookFormDialog.querySelector("#book-form");
        window.bookFormDialog.querySelector('slot[name="hotel-name"]').textContent = hotelName;
        window.bookFormDialog.querySelector('#hotel-id').value = hotelId;

        // Важно: Перепривязываем обработчик после каждого открытия
        form.removeEventListener("submit", book); // Удаляем старый обработчик
        form.addEventListener("submit", book); // Добавляем новый
    });
});

async function book(event) {
    event.preventDefault();

    const form = event.target;
    const url = form.action;
    
    // Собираем данные формы ВКЛЮЧАЯ CSRF-TOKEN
    const formData = new FormData(form);
    
    // Добавляем заголовки для безопасности
    const response = await fetch(url, {
        method: "POST",
        body: formData,
        headers: {
            'X-Requested-With': 'XMLHttpRequest', // Идентификатор AJAX
            'Accept': 'application/json' // Ожидаем JSON ответ
        },
        credentials: 'same-origin' // Важно для передачи куки
    });

    // Обработка ответа
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const result = await response.json();
    
    if (result.message) {
        alert(result.message);
        window.bookFormDialog.close();
    } else {
        alert(result.error || "Unknown error occurred");
    }
}