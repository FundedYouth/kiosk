#!/bin/bash
# ================================
# Raspberry Pi Slideshow Setup Script (Fullscreen Mode with Cache Clearing & Auto-Restart)
# ================================

USER_HOME="$HOME"
USER_NAME=$(whoami)

echo "🔧 Setting up Raspberry Pi Kiosk Mode..."

# 1. Create kiosk.sh launcher with cache clearing
echo "📝 Creating kiosk launcher script..."
cat << 'EOF' > "$USER_HOME/kiosk.sh"
#!/bin/bash

# Log restart for debugging
echo "$(date): Kiosk starting/restarting" >> ~/kiosk_restart.log

# Clear Chromium cache before starting (ensures fresh content)
echo "Clearing browser cache..."
rm -rf ~/.cache/chromium/
rm -rf ~/.config/chromium/Default/Cache/
rm -rf ~/.config/chromium/Default/Code\ Cache/

# Optional: Clear any local storage
rm -rf ~/.config/chromium/Default/Local\ Storage/

# Kill any existing Chromium processes
pkill -f chromium-browser || true

# Small delay to ensure clean shutdown
sleep 2

# Start Chromium in kiosk mode
chromium-browser \
  --start-fullscreen \
  --incognito \
  --disable-cache \
  --disk-cache-size=1 \
  --disable-application-cache \
  --disable-offline-load-stale-cache \
  --aggressive-cache-discard \
  --disable-background-networking \
  --disable-sync \
  --disable-translate \
  --disable-extensions \
  --disable-web-security \
  --disable-features=TranslateUI \
  --disable-component-extensions-with-background-pages \
  https://fundedyouth.org/kiosk/
EOF

chmod +x "$USER_HOME/kiosk.sh"

# 2. Create systemd service file
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/kiosk.service > /dev/null << EOF
[Unit]
Description=Chromium Slideshow (Fullscreen with Cache Clear)
After=graphical.target

[Service]
User=$USER_NAME
Environment=XAUTHORITY=$USER_HOME/.Xauthority
Environment=DISPLAY=:0
ExecStart=$USER_HOME/kiosk.sh
Restart=always
# Restart if it crashes
RestartSec=10

[Install]
WantedBy=graphical.target
EOF

# 3. Set up cron job for periodic restart
echo "⏰ Setting up automatic periodic restart..."

# Create a temporary cron file
CRON_FILE="/tmp/kiosk_cron_$USER_NAME"

# Get existing crontab (if any) and filter out old kiosk entries
crontab -l 2>/dev/null | grep -v "kiosk.service" > "$CRON_FILE" || true

# Add new cron job - restart every 6 hours
echo "0 */6 * * * sudo systemctl restart kiosk.service > /dev/null 2>&1" >> "$CRON_FILE"

# Optional: Add a daily cache cleanup at 3 AM (in case service doesn't restart properly)
echo "0 3 * * * rm -rf ~/.cache/chromium/ ~/.config/chromium/Default/Cache/ > /dev/null 2>&1" >> "$CRON_FILE"

# Install the new crontab
crontab "$CRON_FILE"
rm "$CRON_FILE"

# 4. Ensure sudo works without password for systemctl (for the cron job)
echo "🔐 Configuring sudo permissions for auto-restart..."
sudo tee /etc/sudoers.d/kiosk-restart > /dev/null << EOF
$USER_NAME ALL=(ALL) NOPASSWD: /bin/systemctl restart kiosk.service
$USER_NAME ALL=(ALL) NOPASSWD: /bin/systemctl stop kiosk.service
$USER_NAME ALL=(ALL) NOPASSWD: /bin/systemctl start kiosk.service
EOF

# 5. Enable and start the service
echo "🚀 Starting kiosk service..."
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl restart kiosk.service

# 6. Display configuration summary
echo ""
echo "✅ Slideshow setup complete with:"
echo "   • Cache clearing on each start"
echo "   • Automatic restart every 6 hours"
echo "   • Daily cache cleanup at 3 AM"
echo "   • Crash recovery with 10-second delay"
echo ""
echo "📊 Status Information:"
echo "   • Kiosk script: $USER_HOME/kiosk.sh"
echo "   • Service name: kiosk.service"
echo "   • Restart log: $USER_HOME/kiosk_restart.log"
echo ""
echo "🛠️ Useful commands:"
echo "   • Check status: sudo systemctl status kiosk.service"
echo "   • Manual restart: sudo systemctl restart kiosk.service"
echo "   • View logs: journalctl -u kiosk.service -f"
echo "   • Edit cron: crontab -e"
echo "   • View cron jobs: crontab -l"
echo ""
echo "🎯 The display will show: https://fundedyouth.org/kiosk/"