
function toggleMenu() {
    const sidebar = document.getElementById("sidebar");
    if (sidebar.style.width === "250px") {
        sidebar.style.width = "0";
    } else {
        sidebar.style.width = "250px";
    }
}

function toggleMenu2() {
    const sidebar2 = document.getElementById("sidebar2");
    if (sidebar2.style.width === "150px") {
        sidebar2.style.width = "0";
    } else {
        sidebar2.style.width = "150px";
    }
}

function toggleMenu3() {
    const sidebar3 = document.getElementById("sidebar3");
    if (sidebar3.style.height === "500px") {
        sidebar3.style.height = "0";
    } else {
      sidebar3.style.height = "500px"; // Ajusta según número de enlaces
    }
}