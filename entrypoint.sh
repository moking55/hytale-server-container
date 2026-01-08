#!/bin/sh
set -eu

# Configuration defaults
SCRIPTS_PATH="/usr/local/bin/scripts"
SERVER_PORT="${SERVER_PORT:-25565}"
SERVER_IP="${SERVER_IP:-0.0.0.0}"
AUTO_UPDATE="${AUTO_UPDATE:-false}"
MINECRAFT="${MINECRAFT:-FALSE}" # Added default to prevent crash

. "$SCRIPTS_PATH/utils.sh"

# Minecraft Fallback Logic
if [ "$MINECRAFT" = "TRUE" ]; then
    echo "🎮 MINECRAFT=TRUE: Checking for server JAR..."
    
    # Download to the current working directory (/home/container)
    if [ ! -f "server.jar" ]; then
        echo "📥 Downloading Minecraft Server (Latest Stable)..."
        curl -o server.jar https://piston-data.mojang.com/v1/objects/84100236a2829286d11da9287c88019e34c919d7/server.jar
    else
        echo "✅ server.jar already exists, skipping download."
    fi
fi

# 1. Config & EULA
sh "$SCRIPTS_PATH/checks/server-properties.sh"
sh "$SCRIPTS_PATH/hytale/eula.sh"

# 2. Audits
sh "$SCRIPTS_PATH/checks/network.sh"
sh "$SCRIPTS_PATH/checks/security.sh"

# 3. Pterodactyl Variable Parsing
# Note: Ensure your Pterodactyl Startup string points to the right JAR!
MODIFIED_STARTUP=$(eval echo $(echo "${STARTUP:-java -jar server.jar}" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# 4. Execution
log "🚀 Starting Server..." "$GREEN" "status"
exec ${MODIFIED_STARTUP}