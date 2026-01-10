#!/bin/bash
set -eu

# --- Configuration defaults ---
export SCRIPTS_PATH="/usr/local/bin/scripts"
export PROPERTIES_FILE="server.properties"
export SERVER_PORT="${SERVER_PORT:-25565}"
export SERVER_IP="${SERVER_IP:-0.0.0.0}"
export AUTO_UPDATE="${AUTO_UPDATE:-false}"
export MINECRAFT="${MINECRAFT:-FALSE}"
export SERVER_JAR_PATH="/home/container/server.jar"

# Load utilities
. "$SCRIPTS_PATH/utils.sh"

# --- Minecraft Fallback Logic ---
if [ "${MINECRAFT:-}" = "TRUE" ]; then    
    log_section "Minecraft Fallback Mode"
    
    log_step "Searching for server JAR"
    FOUND_JAR=$(ls /home/container/*server*.jar 2>/dev/null | head -n 1)

    if [ -z "$FOUND_JAR" ]; then
        log_warning "No JAR found." "Attempting to download official Mojang binary."
        
        log_step "Downloading Minecraft Server"
        if curl -sSL -o "$SERVER_JAR_PATH" "https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar"; then
            log_success
            log_step "Securing binary (Read-Only)"
            chmod 444 "$SERVER_JAR_PATH" && log_success || log_error "Failed to set permissions."
        else
            log_error "Download failed." "Check network connectivity or the Mojang URL."
            exit 1
        fi
    else
        log_success
        echo -e "      ${DIM}↳ Found:${NC} ${GREEN}$FOUND_JAR${NC}"
        SERVER_JAR_PATH="$FOUND_JAR"
    fi
fi

# --- 1. Initialization ---
# These scripts use log_section internally
bash "$SCRIPTS_PATH/hytale/eula.sh"
bash "$SCRIPTS_PATH/hytale/server-properties.sh"

# --- 2. Audit Suite ---
bash "$SCRIPTS_PATH/checks/security.sh"
bash "$SCRIPTS_PATH/checks/network.sh"
bash "$SCRIPTS_PATH/checks/prod.sh"

# --- 4. Startup Command Parsing ---
log_section "Process Execution"
log_step "Parsing Startup Command"

# Default if Pterodactyl provides nothing
DEFAULT_STARTUP="java ${JAVA_OPTS:- -Xms128M -Xmx2048M} -jar $SERVER_JAR_PATH"
STARTUP_CMD="${STARTUP:-$DEFAULT_STARTUP}"

# Convert Pterodactyl's {{VARIABLE}} syntax to shell ${VARIABLE} and evaluate
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP_CMD" | sed -e 's/{{/${/g' -e 's/}}/}/g'))
log_success

# --- 5. Execution ---
echo -e "\n${BOLD}${CYAN}🚀 Launching Hytale/Minecraft Server...${NC}\n"
echo -e "${DIM}Command: $MODIFIED_STARTUP${NC}\n"

# Execute and replace the shell process
exec $MODIFIED_STARTUP