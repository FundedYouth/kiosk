#!/bin/bash
# ================================
# Raspberry Pi Kiosk Removal Script
# Complete uninstallation of kiosk setup
# ================================

USER_HOME="$HOME"
USER_NAME=$(whoami)

echo "🗑️ Starting Kiosk Removal Process..."
echo "This will remove all kiosk-related configurations."
echo ""

# Ask for confirmation
read -p "Are you sure you want to remove the kiosk setup? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Removal cancelled."
    exit 1
fi

echo ""
echo "📋 Beginning removal process..."

# 1. Stop and disable the kiosk service
echo "⏹️ Stopping kiosk service..."
sudo systemctl stop kiosk.service 2>/dev/null || true
sudo systemctl disable kiosk.service 2>/dev/null || true

# 2. Remove systemd service file
echo "🗑️ Removing systemd service..."
sudo rm -f /etc/systemd/system/kiosk.service
sudo systemctl daemon-reload

# 3. Kill any remaining Chromium processes
echo "🔪 Killing any remaining Chromium processes..."
pkill -f chromium-browser 2>/dev/null || true

# 4. Remove kiosk launcher script
echo "📝 Removing kiosk launcher script..."
rm -f "$USER_HOME/kiosk.sh"

# 5. Remove cron jobs related to kiosk
echo "⏰ Removing scheduled tasks..."
# Create temporary file with filtered crontab (removing kiosk-related entries)
crontab -l 2>/dev/null | grep -v "kiosk.service" | grep -v "chromium" > /tmp/cleaned_cron_$USER_NAME || true

# Install cleaned crontab (or empty one if no other jobs exist)
if [ -s /tmp/cleaned_cron_$USER_NAME ]; then
    crontab /tmp/cleaned_cron_$USER_NAME
    echo "   Kept other cron jobs, removed kiosk entries"
else
    crontab -r 2>/dev/null || true
    echo "   Removed all cron entries (only kiosk entries existed)"
fi
rm -f /tmp/cleaned_cron_$USER_NAME

# 6. Remove sudo permissions for kiosk
echo "🔐 Removing sudo permissions..."
sudo rm -f /etc/sudoers.d/kiosk-restart

# 7. Clear Chromium cache and config (optional)
echo ""
read -p "Do you want to clear ALL Chromium browser data and cache? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Clearing Chromium data..."
    rm -rf ~/.cache/chromium/
    rm -rf ~/.config/chromium/Default/Cache/
    rm -rf ~/.config/chromium/Default/Code\ Cache/
    rm -rf ~/.config/chromium/Default/Local\ Storage/
    echo "   Chromium cache and data cleared"
else
    echo "   Keeping Chromium browser data"
fi

# 8. Remove log files
echo "📄 Removing log files..."
rm -f "$USER_HOME/kiosk_restart.log"

# 9. Clean up any temporary files
echo "🧹 Cleaning up temporary files..."
rm -f /tmp/kiosk_cron_$USER_NAME 2>/dev/null || true

# 10. Verification
echo ""
echo "🔍 Verifying removal..."

ERRORS=0

# Check if service still exists
if systemctl list-unit-files | grep -q kiosk.service; then
    echo "   ⚠️ Warning: kiosk.service still exists"
    ERRORS=$((ERRORS + 1))
else
    echo "   ✓ Service removed successfully"
fi

# Check if kiosk.sh still exists
if [ -f "$USER_HOME/kiosk.sh" ]; then
    echo "   ⚠️ Warning: kiosk.sh still exists"
    ERRORS=$((ERRORS + 1))
else
    echo "   ✓ Kiosk script removed successfully"
fi

# Check if cron jobs still exist
if crontab -l 2>/dev/null | grep -q "kiosk"; then
    echo "   ⚠️ Warning: Kiosk cron jobs still exist"
    ERRORS=$((ERRORS + 1))
else
    echo "   ✓ Cron jobs removed successfully"
fi

# Check if sudo permissions still exist
if [ -f /etc/sudoers.d/kiosk-restart ]; then
    echo "   ⚠️ Warning: Sudo permissions file still exists"
    ERRORS=$((ERRORS + 1))
else
    echo "   ✓ Sudo permissions removed successfully"
fi

# Final status
echo ""
echo "═══════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "✅ Kiosk setup has been completely removed!"
    echo ""
    echo "The system has been restored to its previous state."
    echo "You can safely delete this remove_kiosk.sh script if desired."
else
    echo "⚠️ Removal completed with $ERRORS warning(s)."
    echo ""
    echo "Some components may need manual removal."
    echo "Check the warnings above for details."
fi
echo "═══════════════════════════════════════"
echo ""

# Optional reboot prompt
read -p "Would you like to reboot now to ensure clean state? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Rebooting system..."
    sudo reboot
else
    echo "ℹ️ You may want to reboot later to ensure a clean state."
    echo "   Use: sudo reboot"
fi