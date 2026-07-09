#!/bin/bash
set -euo pipefail

APP="${OPENCODE_APP:-/Applications/OpenCode.app}"
ASAR="$APP/Contents/Resources/app.asar"
BACKUP="$(ls "$APP/Contents/Resources"/app.asar.backup.* 2>/dev/null | sort | head -n 1 || true)"

echo "OpenCode RTL Fix Restore"
echo "========================"

if [ -z "$BACKUP" ]; then
  echo "No app.asar backup found."
  read -n 1 -s -r -p "Press any key to close..." || true
  exit 1
fi

if pgrep -x "OpenCode" >/dev/null 2>&1; then
  echo "Closing OpenCode..."
  osascript -e 'quit app "OpenCode"' >/dev/null 2>&1 || true
  sleep 2
fi

echo "Restoring oldest backup: $BACKUP"
if cp "$BACKUP" "$ASAR" 2>/dev/null; then
  true
else
  echo "Admin permission is required to modify $APP"
  sudo cp "$BACKUP" "$ASAR"
fi

echo "Done. Restart OpenCode."
read -n 1 -s -r -p "Press any key to close..." || true
