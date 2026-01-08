#!/bin/sh
set -eu

# Source Central Utilities
. "/usr/local/bin/scripts/utils.sh"

# Variable declaration
PROPERTIES_FILE="${HOME}/server.properties"
JAR_PATH="/usr/local/lib/hytale-server.jar"
SCRIPTS_PATH="/usr/local/bin/scripts"

# 1. First-time Download / Auto-Update
# Do this FIRST so scripts have a JAR to inspect if needed
if [ ! -f "$JAR_PATH" ]; then
    log "Hytale JAR missing. Downloading..." "$YELLOW" "setup"
    sh "$SCRIPTS_PATH/hytale/download-server-binary.sh"
else
    # Auto-update logic (checks if a new version is available)
    sh "$SCRIPTS_PATH/hytale/auto-update.sh"
fi

# 2. Environment Checks & EULA
# These ensure the user has accepted terms and config is valid
sh "$SCRIPTS_PATH/hytale/eula.sh"
sh "$SCRIPTS_PATH/checks/server-properties.sh"

# 3. Audits
# Performance and security checks
sh "$SCRIPTS_PATH/checks/network.sh"
sh "$SCRIPTS_PATH/checks/security.sh"

# 4. Pterodactyl Variable Parsing
# Converts {{SERVER_MEMORY}} etc. into usable bash values
MODIFIED_STARTUP=$(eval echo $(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# 5. Execution
# Corrected log order: log "message" "color" "prefix"
log "Running: $MODIFIED_STARTUP" "$GREEN" "status"

# 'exec' ensures Java gets PID 1 to handle SIGTERM (graceful shutdown) correctly

exec ${MODIFIED_STARTUP}