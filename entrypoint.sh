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
    echo "🎮 MINECRAFT=TRUE: Checking for server JAR in /usr/local/lib..."
    
    # Check if JAR exists in the protected library folder
    if [ ! -f "/usr/local/lib/server.jar" ]; then
        echo "📥 Downloading Minecraft Server to protected storage..."
        # Note: This will only work if the hytale user has write access to this folder
        # or if we handle the download as root (see Dockerfile suggestion below)
        curl -L -o /usr/local/lib/server.jar https://piston-data.mojang.com/v1/objects/84100236a2829286d11da9287c88019e34c919d7/server.jar
        
        # Set to Read-Only for everyone
        chmod 444 /usr/local/lib/server.jar
        echo "🔒 File protections enabled: Read-only"
    else
        echo "✅ server.jar already exists in /usr/local/lib."
    fi
    
    # Force the startup command to use this specific path
    # This overrides Pterodactyl's default jar if necessary
    export SERVER_JAR_PATH="/usr/local/lib/server.jar"
fi

# 1. Config & EULA
sh "$SCRIPTS_PATH/checks/server-properties.sh"
sh "$SCRIPTS_PATH/hytale/eula.sh"

# 2. Audits
sh "$SCRIPTS_PATH/checks/network.sh"
sh "$SCRIPTS_PATH/checks/security.sh"

# 3. Pterodactyl Variable Parsing
# We provide a sensible default if STARTUP is empty, using the protected JAR path
DEFAULT_STARTUP="java ${JAVA_OPTS} -jar $SERVER_JAR_PATH"
STARTUP_CMD="${STARTUP:-$DEFAULT_STARTUP}"

# Convert Pterodactyl's {{VARIABLE}} to shell ${VARIABLE} and eval it
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP_CMD" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# 4. Execution
log "🚀 Starting Server..." "$GREEN" "status"
exec $MODIFIED_STARTUP