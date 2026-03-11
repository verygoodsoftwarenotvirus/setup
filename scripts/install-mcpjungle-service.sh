#!/usr/bin/env bash
# Install MCPJungle as a launchd user agent (macOS). Starts at login, restarts if it exits.
# Usage: ./scripts/install-mcpjungle-service.sh
# Requires: mcpjungle (brew install mcpjungle/mcpjungle/mcpjungle)

set -e

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This script is for macOS (launchd). On Linux consider a systemd user service." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
PLIST_SRC="$SETUP_DIR/config/com.mcpjungle.server.plist.template"
PLIST_DST="$HOME/Library/LaunchAgents/com.mcpjungle.server.plist"
STATE_DIR_ABS="${MCPJUNGLE_STATE_DIR:-$HOME/.local/state/mcpjungle}"

if ! command -v mcpjungle >/dev/null 2>&1; then
  echo "mcpjungle not found. Install with: brew install mcpjungle/mcpjungle/mcpjungle" >&2
  exit 1
fi

MCPJUNGLE_PATH="$(command -v mcpjungle)"
mkdir -p "$STATE_DIR_ABS"

sed -e "s|@MCPJUNGLE_PATH@|$MCPJUNGLE_PATH|g" \
    -e "s|@STATE_DIR@|$STATE_DIR_ABS|g" \
    "$PLIST_SRC" > "$PLIST_DST"

echo "Installed $PLIST_DST (state/logs: $STATE_DIR_ABS)"

# Reload so any plist changes take effect
launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load "$PLIST_DST"
echo "MCPJungle service loaded. It will start at login and keep running."
echo "Logs: $STATE_DIR_ABS/stdout.log $STATE_DIR_ABS/stderr.log"
echo "Stop: launchctl unload $PLIST_DST"
echo "Start: launchctl load $PLIST_DST"
