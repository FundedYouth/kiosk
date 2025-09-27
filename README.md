# Kiosk

A php web app that displays the latest notifications on FundedYouth.org/kiosk/

## Settings

- Edit file: `config.php`

```php
// Global Settings

// Time between images (in milliseconds)
// Example: 5000 = 5 seconds
$slideshow_interval = 5000;

// Enable or disable fade effect
// true = fade transition, false = instant image switch
$enable_fade = true;

// Time between full page reloads (in milliseconds)
// Example: 3600000 = 1 hour
$page_reload_time = 3600000;
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

1. Download: [kiosk_setup.sh](https://www.FundedYouth.org/kiosk/download/kiosk_setup.sh)

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
