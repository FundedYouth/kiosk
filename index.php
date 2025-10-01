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

        .media-item {
            max-width: 100%;
            max-height: 100%;
            position: absolute;
            transition: opacity 1s;
            opacity: 0;
            object-fit: contain;
            /* Change to 'cover' if you want to fill screen */
        }

        .media-item.active {
            opacity: 1;
            z-index: 10;
        }

        video {
            width: 100%;
            height: 100%;
        }
    </style>
</head>

<body>
    <script>
        // Config from PHP
        const SLIDESHOW_INTERVAL = <?= $slideshow_interval ?>;
        const ENABLE_FADE = <?= $enable_fade ? 'true' : 'false' ?>;
        const PAGE_RELOAD_TIME = <?= $page_reload_time ?>;

        let mediaItems = [];
        let index = 0;
        let updateCheckInterval;
        let currentTimer;

        // Check if file is a video
        function isVideo(src) {
            return src.toLowerCase().match(/\.(mp4|webm|ogg)$/);
        }

        // Function to check for updates
        async function checkForUpdates() {
            try {
                const response = await fetch("media.json?t=" + Date.now());
                const newData = await response.json();

                // Compare with current data
                if (mediaItems.length !== newData.length ||
                    JSON.stringify(newData) !== JSON.stringify(window.currentMediaData)) {
                    console.log("Media changes detected, reloading...");
                    location.reload(true);
                }
            } catch (error) {
                console.error("Error checking for updates:", error);
            }
        }

        // Load media.json (with fallback to images.json for backward compatibility)
        fetch("media.json?t=" + Date.now())
            .then(response => {
                if (!response.ok) {
                    throw new Error('media.json not found, trying images.json');
                }
                return response.json();
            })
            .catch(() => {
                // Fallback to images.json for backward compatibility
                console.log('media.json not found, falling back to images.json');
                return fetch("images.json?t=" + Date.now()).then(r => r.json());
            })
            .then(data => {
                window.currentMediaData = data; // Store for comparison
                const container = document.body;

                data.forEach((item, i) => {
                    // More aggressive cache-busting with timestamp
                    let src = item.src + "?v=" + item.version + "&t=" + Date.now();
                    let element;

                    if (isVideo(item.src)) {
                        // Create video element
                        element = document.createElement("video");
                        element.className = "media-item";
                        element.src = src;
                        element.muted = true; // Required for autoplay
                        element.playsInline = true;
                        element.preload = "auto";

                        // Store video-specific settings
                        element.dataset.type = 'video';
                        element.dataset.loop = item.loop !== false; // Loop by default
                        element.dataset.duration = item.duration || null;

                        // Handle video ending
                        element.addEventListener('ended', function () {
                            if (element.dataset.loop === 'false') {
                                showNextMedia();
                            }
                        });

                    } else {
                        // Create image element
                        element = document.createElement("img");
                        element.className = "media-item";
                        element.src = src;
                        element.setAttribute('crossorigin', 'anonymous');

                        // Store image settings
                        element.dataset.type = 'image';
                        element.dataset.duration = item.duration || SLIDESHOW_INTERVAL;
                    }

                    if (i === 0) element.classList.add("active");
                    container.appendChild(element);
                    mediaItems.push(element);
                });

                // Start slideshow
                if (mediaItems.length > 0) {
                    playCurrentMedia();
                }

                // Check for updates every 30 seconds
                updateCheckInterval = setInterval(checkForUpdates, 30000);
            })
            .catch(error => {
                console.error('Error loading media:', error);
            });

        function playCurrentMedia() {
            const current = mediaItems[index];

            // Clear any existing timer
            if (currentTimer) {
                clearTimeout(currentTimer);
            }

            if (current.dataset.type === 'video') {
                // Reset and play video
                current.currentTime = 0;
                current.play().catch(e => {
                    console.error('Error playing video:', e);
                    // Move to next if video fails
                    setTimeout(showNextMedia, 1000);
                });

                // If video loops, set timer for specified duration or skip
                if (current.dataset.loop === 'true') {
                    const duration = current.dataset.duration ||
                        (SLIDESHOW_INTERVAL * 2); // Default: 2x normal interval for videos
                    currentTimer = setTimeout(showNextMedia, duration);
                }
                // If video doesn't loop, it will trigger 'ended' event

            } else {
                // Image - set timer for next media
                const duration = parseInt(current.dataset.duration) || SLIDESHOW_INTERVAL;
                currentTimer = setTimeout(showNextMedia, duration);
            }
        }

        function showNextMedia() {
            const current = mediaItems[index];

            // Stop current media if it's a video
            if (current.dataset.type === 'video') {
                current.pause();
                current.currentTime = 0;
            }

            // Hide current
            current.classList.remove("active");

            // Move to next
            index = (index + 1) % mediaItems.length;
            const next = mediaItems[index];

            // Show next
            next.classList.add("active");

            if (!ENABLE_FADE) {
                mediaItems.forEach((item, i) => {
                    item.style.transition = "none";
                    item.style.opacity = i === index ? "1" : "0";
                });
            }

            // Play next media
            playCurrentMedia();
        }

        // Reload whole page every X ms
        setInterval(() => location.reload(true), PAGE_RELOAD_TIME);

        // Listen for visibility changes to force refresh
        document.addEventListener("visibilitychange", function () {
            if (!document.hidden) {
                checkForUpdates();
            }
        });
    </script>
</body>

</html>