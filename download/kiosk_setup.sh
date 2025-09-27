#!/bin/bash
# ================================
# Raspberry Pi Kiosk Setup Script
# ================================

# 1. Create kiosk.sh launcher
cat << 'EOF' > /home/pi/kiosk.sh
#!/bin/bash
chromium-browser \
  --kiosk \
  --incognito \
  --disable-cache \
  --disk-cache-size=1 \
  --disable-application-cache \
  --disable-offline-load-stale-cache \
  https://fundedyouth.org/kiosk/display.php
EOF

chmod +x /home/pi/kiosk.sh

# 2. Create systemd service file
sudo tee /etc/systemd/system/kiosk.service > /dev/null << EOF
[Unit]
Description=Chromium Kiosk
After=graphical.target

[Service]
User=pi
Environment=XAUTHORITY=/home/pi/.Xauthority
Environment=DISPLAY=:0
ExecStart=/home/pi/kiosk.sh
Restart=always

[Install]
WantedBy=graphical.target
EOF

# 3. Enable + start the service
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

echo "✅ Kiosk setup complete. Chromium will now auto-start in kiosk mode on boot."
