#!/bin/sh

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

# Shared download function
perform_hytale_download() {
    local path="$1"
    log "Initiating Hytale Server JAR download..." "$BLUE" "updater"
    
    # Temporarily allow writing if the file already exists
    [ -f "$path" ] && chmod 644 "$path"
    
    # Run downloader
    if hytale-downloader download --output "$path"; then
        chmod 444 "$path"
        log "Download successful. Permissions locked to 444 (Read-Only)." "$GREEN" "updater"
    else
        log "CRITICAL: Download failed!" "$RED" "updater"
        return 1
    fi
}