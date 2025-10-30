const toggler = document.querySelector(".button-sidebar");
// toggler.addEventListener("click", function () {

//     document.querySelector("#sidebar").classList.toggle("collapsed");

// });

// var lastWindowWidth = 0;

// window.addEventListener('resize', checkScreenSize);
// function checkScreenSize(isFirstLoad = false) {
//     if (lastWindowWidth === window.innerWidth) {
//         return;
//     }

//     lastWindowWidth = window.innerWidth;

//     const element = document.getElementById("sidebar");
//     if (window.innerWidth < 750) {
//         if (isFirstLoad) {
//             element.style.display = "none";
//             setTimeout(() => {
//                 element.style.display = "block";
//             }, 500);
//         }
//         document.querySelector("#sidebar").classList.add("collapsed");
//     } else {
//         document.querySelector("#sidebar").classList.remove("collapsed");
//     }
// }

// checkScreenSize(true);

$(document).ready(function () {
    $(".js-delete-links").on("click", function (e) {
        e.preventDefault();
        const url = $(this).data("href");
        const message = $(this).data("message") ?? "Are you sure you want to delete this item?";
        if (confirm(message)) {
            window.location.href = url;
        }
    });
});