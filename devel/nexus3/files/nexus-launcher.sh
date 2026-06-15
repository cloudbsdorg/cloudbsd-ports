#!/bin/sh
#
# Nexus3 launcher - opens browser to Nexus Repository Manager
# Dynamically reads port from nexus.conf
#

NEXUS_CONF="${NEXUS_CONF:-/usr/local/etc/nexus/nexus.conf}"
NEXUS_HOME="${NEXUS_HOME:-/usr/local/nexus3}"

# Source nexus configuration if it exists
if [ -f "$NEXUS_CONF" ]; then
    . "$NEXUS_CONF"
fi

# Default values
NEXUS_PORT="${NEXUS_PORT:-8081}"
NEXUS_HOST="${NEXUS_HOST:-localhost}"
NEXUS_URL="http://${NEXUS_HOST}:${NEXUS_PORT}/"

# Check if nexus is running
if ! service nexus3 status >/dev/null 2>&1; then
    echo "Nexus3 is not running."
    echo "Start it with: service nexus3 start"
    exit 1
fi

# Open browser (supports multiple desktop environments)
open_url() {
    case "$(uname)" in
        *Darwin*)
            open "$NEXUS_URL"
            ;;
        *)
            # Linux/FreeBSD - try various browsers
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$NEXUS_URL"
            elif command -v gnome-open >/dev/null 2>&1; then
                gnome-open "$NEXUS_URL"
            elif command -v firefox >/dev/null 2>&1; then
                firefox "$NEXUS_URL"
            elif command -v chromium >/dev/null 2>&1; then
                chromium "$NEXUS_URL"
            else
                echo "No browser found. Open: $NEXUS_URL"
                exit 1
            fi
            ;;
    esac
}

echo "Opening Nexus3 at $NEXUS_URL"
open_url
