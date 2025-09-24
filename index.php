<?php include("config.php"); ?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Dynamic Slideshow</title>
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

        // Load images.json
        fetch("images.json?t=" + Date.now()) // cache-busting for the JSON file itself
            .then(response => response.json())
            .then(data => {
                const container = document.body;

                data.forEach((item, i) => {
                    // Append version number for cache-busting
                    let src = item.src + "?v=" + item.version;

                    const img = document.createElement("img");
                    img.src = src;
                    if (i === 0) img.classList.add("active");
                    container.appendChild(img);
                    slides.push(img);
                });

                // Start slideshow
                setInterval(showNextSlide, SLIDESHOW_INTERVAL);
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
    </script>
</body>

</html>