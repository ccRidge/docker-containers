#!/bin/bash
set -u

echo "=========================================="
echo " PowerShell Scheduler"
echo "=========================================="
echo "PowerShell version:"
pwsh --version

# ============================================================
# Configure system timezone
# ============================================================
if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

echo
echo "Timezone:"
echo "  TZ=${TZ:-<not set>}"
echo "  System timezone: $(cat /etc/timezone 2>/dev/null || echo '<unknown>')"
echo "  Current time:    $(date '+%Y-%m-%d %H:%M:%S.%4N %Z %z')"

# ============================================================
# Validate directories
# ============================================================
echo
echo "Checking configuration..."
for DIR in /config /scripts /logs; do
    if [ ! -d "$DIR" ]; then
        echo "ERROR: Required directory does not exist: $DIR"
        exit 1
    fi
done
for INTERVAL in minute hourly daily weekly monthly; do
    for DIR in /scripts /logs; do
        if [ ! -d "/$DIR/$INTERVAL" ]; then
            echo "Creating directory: /$DIR/$INTERVAL"
            mkdir -p "/$DIR/$INTERVAL"
        fi
    done
done

# ============================================================
# Configure anacron
# ============================================================
ANACRON_SPOOL="/config/anacron"
mkdir -p "$ANACRON_SPOOL"

ANACRON_CONFIG="/config/anacrontab"
if [ ! -f "$ANACRON_CONFIG" ]; then
    echo "Creating anacrontab..."

    cat > "$ANACRON_CONFIG" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

1       0       powershell-daily      /usr/local/bin/run-powershell-directory daily
7       0       powershell-weekly     /usr/local/bin/run-powershell-directory weekly
30      0       powershell-monthly    /usr/local/bin/run-powershell-directory monthly
EOF
fi

echo
echo "Anacron configuration:"
echo "------------------------------------------"
cat "$ANACRON_CONFIG"
echo "------------------------------------------"

echo
echo "Testing anacron configuration..."

anacron -T -t "$ANACRON_CONFIG"

echo "Anacron configuration valid."

# ============================================================
# Align to the next HH:MM:00 boundary
# ============================================================
wait_for_next_minute() {
    local seconds
    local sleep_seconds
    seconds="$(date '+%S')"
    sleep_seconds=$((60 - 10#$seconds))
    sleep "$sleep_seconds"
}
echo
echo "Waiting for next minute boundary..."
wait_for_next_minute

# ============================================================
# Scheduler
# ============================================================
echo
echo "Starting scheduler..."
echo

while true; do
    CURRENT_MINUTE="$(date '+%M')"
    echo "$(date '+%Y-%m-%d %H:%M:%S.%4N') INFO: Scheduler cycle started."

    # Run minute jobs.
    /usr/local/bin/run-powershell-directory minute &

    # Run hourly jobs at the top of the hour.
    if [ "$CURRENT_MINUTE" = "00" ]; then
        /usr/local/bin/run-powershell-directory hourly &
    fi

    # Run daily/weekly/monthly jobs through Anacron.
    anacron -d -s -S "$ANACRON_SPOOL" -t "$ANACRON_CONFIG"

    echo "$(date '+%Y-%m-%d %H:%M:%S.%4N') INFO: Scheduler cycle completed."

    # Wait for the next minute boundary.
    wait_for_next_minute
done
