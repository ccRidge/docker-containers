#!/bin/bash

set -e

echo "=========================================="
echo " PowerShell Scheduler"
echo "=========================================="

echo "PowerShell version:"
pwsh --version

# ============================================================
# Configure system timezone
# ============================================================
# NEW: Set the container's system timezone from the TZ
# environment variable. This is important for cron, which
# uses the system timezone rather than relying solely on TZ.
# ============================================================

if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

echo
echo "Timezone:"
echo "  TZ=${TZ:-<not set>}"
echo "  System timezone: $(cat /etc/timezone 2>/dev/null || echo '<unknown>')"
echo "  Current time:    $(date '+%Y-%m-%d %H:%M:%S %Z %z')"

echo
echo "Checking configuration..."

if [ ! -f /config/crontab ]; then
    echo "ERROR: /config/crontab does not exist."
    echo
    echo "Create:"
    echo "  /mnt/user/appdata/docker/powershell-scheduler/config/crontab"
    echo
    exit 1
fi

if [ ! -d /scripts ]; then
    echo "ERROR: /scripts does not exist."
    exit 1
fi

if [ ! -d /logs ]; then
    echo "ERROR: /logs does not exist."
    exit 1
fi

# Install the user-provided crontab
echo "Installing crontab..."
crontab /config/crontab

echo
echo "Installed schedule:"
echo "------------------------------------------"
crontab -l
echo "------------------------------------------"

echo
echo "Scripts:"
find /scripts -maxdepth 1 -type f -name "*.ps1" -printf "  %f\n" 2>/dev/null || true

echo
echo "Starting cron..."
echo

# Run cron in the foreground so Docker considers the container alive.
exec cron -f
