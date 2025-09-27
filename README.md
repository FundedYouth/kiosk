# Kiosk

<a href="https://www.php.net/" target="_blank"><img src="readme-media/php-logo.png" style="width: 100px;" alt="PHP logo" /></a>
<a href="https://www.raspberrypi.com/software/" target="_blank"><img src="readme-media/raspberry-pi-os.png" style="width: 100px;" alt="Raspberry Pi OS" /></a>
<a href="https://en.wikipedia.org/wiki/Bash_(Unix_shell)" target="_blank"><img src="readme-media/bash-logo.png" style="width: 100px;" alt="Bash logo" /></a>

This a simulated kiosk app that runs using a PHP Website in conjunction with a Raspberry PI.

▶ This is run on a shared hosting service `hostinger.com`. The website displays the latest banners.

▶ While the Raspberry Pi runs a full-screen browser without cache

▶ checks every 30 seconds for any changes

▶ Refreshes the site only if changes are found.

You only need to add images and update the images.json -
Read the documentation below for configuration.

> Basically a cookie cutter push system

## Settings

- Edit file: `config.php`

```php
// Global Settings

// Time between images (in milliseconds)
// $slideshow_interval = 5000; // 5 seconds
$slideshow_interval = 10000; // 10 seconds

// Enable or disable fade effect
// true = fade transition, false = instant image switch
$enable_fade = true;

// Time between full page reloads (in milliseconds)
// $page_reload_time = 3600000; // 1 hour
$page_reload_time = 3600000; // 5 hour
```

## Images

References the `images` directory. If the same images is updated and keeps the same name then update the `version` number so it correctly updates. Update version by `+1`

```json
[
  {
    "src": "images/3dprinting.png",
    "version": 1
  },
  {
    "src": "images/3dmodeling.png",
    "version": 1
  }
]
```

## Operating System Configuration

### Raspberry PI (Raspbian Desktop)

#### Setup Kiosk Script

1. Download: `/download/setup_kiosk.sh`

2. Make it executable:

```bash
chmod +x setup_kiosk.sh
```

3. Run it:

```bash
./setup_kiosk.sh
```

4. Reboot to test

```bash
sudo reboot
```

#### Remove Kiosk Script

1. Downlaod: `remove_kiosk.sh`
2. Then make it writeable `chmod +x remove_kiosk.sh
3. Run it: `./remove_kiosk.sh`
4. Confirm it is no longer running: `systemctl status kiosk.service`
