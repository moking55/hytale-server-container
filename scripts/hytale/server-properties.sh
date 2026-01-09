#!/bin/sh
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

# Only run if the file exists
if [ -f "$PROPERTIES_FILE" ]; then
    log "[init]" "Syncing existing server.properties (Port: $SERVER_PORT)..." "$CYAN"
    sed -i "s/^server-ip=.*/server-ip=$SERVER_IP/" "$PROPERTIES_FILE"
    sed -i "s/^server-port=.*/server-port=$SERVER_PORT/" "$PROPERTIES_FILE"
else
    log "[init]" "server.properties not found. Skipping auto-config." "$YELLOW"
fi