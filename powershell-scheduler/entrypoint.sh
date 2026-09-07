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

for DIR in /config /scripts /logs; do
    if [ ! -d "$DIR" ]; then
        echo "ERROR: Required directory does not exist: $DIR"
        exit 1
    fi
done

for INTERVAL in minute hourly daily weekly monthly; do
    if [ ! -d "/scripts/$INTERVAL" ]; then
        echo "Creating script directory: /scripts/$INTERVAL"
        mkdir -p "/scripts/$INTERVAL"
    fi
done

# ============================================================
# Configure anacron
# ============================================================

ANACRON_SPOOL="/config/anacron"
ANACRON_CONFIG="/config/anacrontab"

mkdir -p "$ANACRON_SPOOL"

cat > "$ANACRON_CONFIG" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

1       0       powershell-daily      /usr/local/bin/run-powershell-directory daily
7       0       powershell-weekly     /usr/local/bin/run-powershell-directory weekly
30      0       powershell-monthly    /usr/local/bin/run-powershell-directory monthly
EOF

echo
echo "Anacron configuration:"
echo "------------------------------------------"
cat "$ANACRON_CONFIG"
echo "------------------------------------------"

echo
echo "Anacron spool:"
echo "  $ANACRON_SPOOL"

# ============================================================
# Start anacron
# ============================================================

echo
echo "Starting anacron..."
echo

exec anacron -f -S "$ANACRON_SPOOL" -t "$ANACRON_CONFIG"
