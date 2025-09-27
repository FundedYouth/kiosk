#!/bin/bash
# ================================
# Remove Raspberry Pi Kiosk Service
# ================================

SERVICE_NAME="kiosk.service"
USER_HOME="$HOME"
KIOSK_SCRIPT="$USER_HOME/kiosk.sh"

echo "🛑 Stopping $SERVICE_NAME..."
sudo systemctl stop $SERVICE_NAME 2>/dev/null

echo "🚫 Disabling $SERVICE_NAME..."
sudo systemctl disable $SERVICE_NAME 2>/dev/null

echo "🗑️ Removing service file..."
sudo rm -f /etc/systemd/system/$SERVICE_NAME

echo "🗑️ Reloading systemd..."
sudo systemctl daemon-reload

# Optional: remove kiosk.sh launcher script
if [ -f "$KIOSK_SCRIPT" ]; then
    echo "🗑️ Removing $KIOSK_SCRIPT..."
    rm -f "$KIOSK_SCRIPT"
fi

echo "✅ Kiosk service removed successfully."
