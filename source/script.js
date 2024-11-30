const calendar_container = document.getElementById("calendar_container");
const calendar_gifts_container = document.getElementById("calendar_gifts_container");

let calendar_opened = false;
let calendar_gifts = {};
let calendar_last = 0;

addEventListener("message", (e) => {
    const data = e.data;

    switch (data.type) {
        case 'calendar:open':
            calendar_gifts = data.gifts
            calendar_open();
        break;
    }
})

addEventListener("keydown", (e) => {
    if(e.key === "Escape" && calendar_opened) {
        calendar_close();
    }
})

window.SendLUAMessage = (name, data = {}) => {
    const resourceName = GetParentResourceName();

    fetch(`https://${resourceName}/${name}`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(data)
    }).catch(error => {
        return;
    });
};

calendar_open = () => {
    if (calendar_opened) return;
    calendar_setup()

    calendar_opened = true;

    calendar_container.classList.remove("hide")
}

calendar_setup = () => {
    calendar_gifts_container.innerHTML = ""

    for (let i = 1; i < 26; i++) {
        const giftItem = document.createElement("div");
        giftItem.className = "calendar-gift";

        if (!calendar_gifts[i].canOpen) {
            giftItem.classList.add("disabled");
        }

        const giftDay = document.createElement("p");
        giftDay.classList.add("calendar-gift-day");
        giftDay.innerText = `#${i}`;

        giftItem.appendChild(giftDay);

        const giftImage = document.createElement("img");
        giftImage.classList.add("calendar-gift-image");
        giftImage.src = "images/gift.png";

        giftItem.appendChild(giftImage);

        const giftText = document.createElement("p");
        giftText.classList.add("calendar-gift-text");
        giftText.innerText = "RÉCUPÉRER";

        giftItem.appendChild(giftText);

        giftItem.addEventListener("click", () => {
            if (calendar_gifts[i].canOpen) {
                const sound = new Audio("sounds/select.mp3");
                sound.volume = 0.02;
                sound.play();

                giftItem.classList.add("disabled");
                window.SendLUAMessage("calendar:claim")
            }
        })

        giftItem.addEventListener("mouseover", () => {
            if (calendar_last === i) return;
            calendar_last = i;

            const sound = new Audio("sounds/hover.mp3");
            sound.volume = 0.02;
            sound.play();
        })

        calendar_gifts_container.appendChild(giftItem);
    }
}

calendar_close = () => {
    calendar_container.classList.add("hide")
    calendar_opened = false
    window.SendLUAMessage("calendar:close")
}