<?php
include("config.php");
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");
header("Expires: 0");
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Dynamic Slideshow</title>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <style>
        body {
            margin: 0;
            background: black;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            overflow: hidden;
        }

        img {
            max-width: 100%;
            max-height: 100%;
            position: absolute;
            transition: opacity 1s;
            opacity: 0;
        }

        img.active {
            opacity: 1;
        }
    </style>
</head>

<body>
    <script>
        // Config from PHP
        const SLIDESHOW_INTERVAL = <?= $slideshow_interval ?>;
        const ENABLE_FADE = <?= $enable_fade ? 'true' : 'false' ?>;
        const PAGE_RELOAD_TIME = <?= $page_reload_time ?>;

        let slides = [];
        let index = 0;
        let imageCheckInterval;

        // Function to check for image updates
        async function checkForUpdates() {
            try {
                const response = await fetch("images.json?t=" + Date.now());
                const newData = await response.json();

                // Compare with current slides
                if (slides.length !== newData.length ||
                    JSON.stringify(newData) !== JSON.stringify(window.currentImageData)) {
                    console.log("Image changes detected, reloading...");
                    location.reload(true);
                }
            } catch (error) {
                console.error("Error checking for updates:", error);
            }
        }

        // Load images.json
        fetch("images.json?t=" + Date.now())
            .then(response => response.json())
            .then(data => {
                window.currentImageData = data; // Store for comparison
                const container = document.body;

                data.forEach((item, i) => {
                    // More aggressive cache-busting with timestamp
                    let src = item.src + "?v=" + item.version + "&t=" + Date.now();

                    const img = document.createElement("img");
                    img.src = src;
                    // Force reload from server
                    img.setAttribute('crossorigin', 'anonymous');
                    if (i === 0) img.classList.add("active");
                    container.appendChild(img);
                    slides.push(img);
                });

                // Start slideshow
                setInterval(showNextSlide, SLIDESHOW_INTERVAL);

                // Check for updates every 30 seconds
                imageCheckInterval = setInterval(checkForUpdates, 30000);
            });

        function showNextSlide() {
            slides[index].classList.remove("active");
            index = (index + 1) % slides.length;
            slides[index].classList.add("active");

            if (!ENABLE_FADE) {
                slides.forEach((img, i) => {
                    img.style.transition = "none";
                    img.style.opacity = i === index ? "1" : "0";
                });
            }
        }

        // Reload whole page every X ms
        setInterval(() => location.reload(true), PAGE_RELOAD_TIME);

        // Additional: Listen for visibility changes to force refresh
        document.addEventListener("visibilitychange", function () {
            if (!document.hidden) {
                checkForUpdates();
            }
        });
    </script>
</body>

</html>