#!/bin/sh

# Load dependencies
. "$(dirname "$0")/../../utils.sh"
. "$(dirname "$0")/lib/update_logic.sh"

JAR_PATH="/usr/local/lib/hytale-server.jar"
AUTO_UPDATE=${AUTO_UPDATE:-false}

if [ -f "$JAR_PATH" ]; then
    log "Checking for Hytale updates..." "$BLUE" "updater"
    
    if [ "$(hytale-downloader check-update)" = "true" ]; then
        if [ "$AUTO_UPDATE" = "true" ]; then
            perform_hytale_download "$JAR_PATH"
        else
            log "UPDATE AVAILABLE! Run 'update.sh' manually to apply." "$YELLOW" "updater"
        fi
    else
        log "Server JAR is already the latest version." "$GREEN" "updater"
    fi
fi