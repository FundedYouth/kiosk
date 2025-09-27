#!/bin/bash
# ================================
# Raspberry Pi Kiosk Setup Script
# ================================

USER_HOME="$HOME"
USER_NAME=$(whoami)

# 1. Create kiosk.sh launcher
cat << 'EOF' > "$USER_HOME/kiosk.sh"
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

chmod +x "$USER_HOME/kiosk.sh"

# 2. Create systemd service file
sudo tee /etc/systemd/system/kiosk.service > /dev/null << EOF
[Unit]
Description=Chromium Kiosk
After=graphical.target

[Service]
User=$USER_NAME
Environment=XAUTHORITY=$USER_HOME/.Xauthority
Environment=DISPLAY=:0
ExecStart=$USER_HOME/kiosk.sh
Restart=always

[Install]
WantedBy=graphical.target
EOF

# 3. Enable + start the service
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

echo "✅ Kiosk setup complete. Chromium will now auto-start in kiosk mode on boot."
