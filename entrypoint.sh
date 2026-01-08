#!/bin/sh
set -eu

# Configuration defaults
SCRIPTS_PATH="/usr/local/bin/scripts"
SERVER_PORT="${SERVER_PORT:-25565}"
SERVER_IP="${SERVER_IP:-0.0.0.0}"
AUTO_UPDATE="${AUTO_UPDATE:-false}"
MINECRAFT="${MINECRAFT:-FALSE}" 

# Load utilities (like the 'log' function)
. "$SCRIPTS_PATH/utils.sh"

# Set the default JAR path (Hytale)
SERVER_JAR_PATH="hytale-server.jar"

# Minecraft Fallback Logic
if [ "$MINECRAFT" = "TRUE" ]; then
    SERVER_JAR_PATH="/home/container/server.jar"
    
    echo "🎮 MINECRAFT=TRUE: Checking for server.jar in root..."
    
    if [ ! -f "$SERVER_JAR_PATH" ]; then
        echo "📥 Downloading Minecraft Server to root..."
        
        # Download directly to the current directory
        curl -L -o "$SERVER_JAR_PATH" https://piston-data.mojang.com/v1/objects/84100236a2829286d11da9287c88019e34c919d7/server.jar
        
        # Set to Read-Only (r--r--r--)
        chmod 444 "$SERVER_JAR_PATH"
        echo "🔒 File protections enabled: Read-only (server.jar)"
    else
        echo "✅ server.jar already exists in root."
    fi
fi

# 1. Config & EULA
sh "$SCRIPTS_PATH/hytale/server-properties.sh"
sh "$SCRIPTS_PATH/hytale/eula.sh"

# 2. Audits
sh "$SCRIPTS_PATH/checks/network.sh"
sh "$SCRIPTS_PATH/checks/security.sh"

# 3. Pterodactyl Variable Parsing
DEFAULT_STARTUP="java ${JAVA_OPTS:- -Xms128M -Xmx2048M} -jar $SERVER_JAR_PATH"
STARTUP_CMD="${STARTUP:-$DEFAULT_STARTUP}"

# Convert Pterodactyl's {{VARIABLE}} to shell ${VARIABLE} and eval it
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP_CMD" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# 4. Execution
log "🚀 Starting Server..." "$GREEN" "status"
exec $MODIFIED_STARTUP