#!/bin/sh
set -eu

# Use absolute paths to avoid confusion
SCRIPTS_PATH="/usr/local/bin/scripts"
. "$SCRIPTS_PATH/utils.sh"

# Configuration defaults
SERVER_PORT="${SERVER_PORT:-25565}"
SERVER_IP="${SERVER_IP:-0.0.0.0}"
SERVER_JAR_PATH="/usr/local/lib/hytale-server.jar"
AUTO_UPDATE=${AUTO_UPDATE:-false}

# 1. Hytale JAR Management
if [ ! -f "$SERVER_JAR_PATH" ]; then
    log "Initial setup: Download JAR" "$YELLOW" "setup"
    # Ensure this filename matches your repo exactly
    sh "$SCRIPTS_PATH/hytale/download-server-binary.sh"
else
    # Auto-update check
    sh "$SCRIPTS_PATH/hytale/auto-update.sh"
fi

# 2. Config & EULA (Found in /scripts/hytale/)
sh "$SCRIPTS_PATH/checks/server-properties.sh"
sh "$SCRIPTS_PATH/hytale/eula.sh"

# 3. Audits (Found in /scripts/checks/)
sh "$SCRIPTS_PATH/checks/network.sh"
sh "$SCRIPTS_PATH/checks/security.sh"

# 4. Pterodactyl Variable Parsing
MODIFIED_STARTUP=$(eval echo $(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# 5. Execution
log "Starting Hytale..." "$GREEN" "status"
exec ${MODIFIED_STARTUP}