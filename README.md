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

- Uses `Chromimum`
- In your terminal run:

```bash
# Run this to open your page in kiosk mode (full screen, no cache):

chromium-browser \
  --kiosk \
  --incognito \
  --disable-cache \
  --disk-cache-size=1 \
  --disable-application-cache \
  --disable-offline-load-stale-cache \
  https://fundedyouth.org/kiosk/display.php
```

- Auto-start Chromium on boot

```bash
# Create the autostart file:

mkdir -p ~/.config/lxsession/LXDE-pi/
nano ~/.config/lxsession/LXDE-pi/autostart

# Add this line and save:

@chromium-browser --kiosk --incognito --disable-cache --disk-cache-size=1 --disable-application-cache --disable-offline-load-stale-cache https://fundedyouth.org/kiosk/index.php

```

- Disable screen blanking (optional, recommended)

```bash
# Install tools:

sudo apt install -y x11-xserver-utils
```

- Edit autostart again:

```bash
nano ~/.config/lxsession/LXDE-pi/autostart

# Then add these lines to prevent the screen from turning off

@xset s off
@xset -dpms
@xset s noblank
```

- Reboot the machine: Manually or using Terminal

```bash
sudo reboot
```

- (Optional) Add Failsafe Cron Job to Chromium

1. Edit the Pi's crontab

```bash
# choose nano is prompted

crontab -e
```

2. Add this job at the bottom

```bash
# Example: restart Chromium every 6 hours

0 */6 * * * pkill -f chromium-browser && sleep 5 && chromium-browser --kiosk --incognito --disable-cache --disk-cache-size=1 --disable-application-cache --disable-offline-load-stale-cache https://fundedyouth.org/kiosk/index.php &

```

**Crontab Explained**

- 0 _/6 _ \* \* → runs at minute 0 every 6 hours
- pkill -f chromium-browser → kills any running Chromium process
- sleep 5 → waits 5 seconds
- Then launches Chromium again with your kiosk options

3. Daily Reboot addition. (Not required)

```bash
# Some people prefer a clean reboot every night at 3 AM:

0 3 * * * /sbin/reboot
```
