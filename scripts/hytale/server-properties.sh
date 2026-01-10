#!/bin/bash
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

log_section "Server Configuration"

# Only run if the file exists
if [ -f "${PROPERTIES_FILE:-}" ]; then
    log_step "Syncing server.properties"

    # We "build" our array of sed commands here
    # Using the safest way to handle positional parameters
    set -- \
        -e "s/^server-ip=.*/server-ip=${SERVER_IP:-}/" \
        -e "s/^server-port=.*/server-port=${SERVER_PORT:-23000}/" \
        -e "s/^query.port=.*/query.port=${SERVER_PORT:-23000}/" \
        -e "s/^rcon.port=.*/rcon.port=${RCON_PORT:-25575}/"

    # Process content and update file
    if UPDATED_CONTENT=$(sed "$@" "$PROPERTIES_FILE"); then
        echo "$UPDATED_CONTENT" > "$PROPERTIES_FILE"
        log_success
    else
        log_error "Sync failed." "Check if $PROPERTIES_FILE is writable or if sed is installed."
        exit 1
    fi

else
    log_warning "Properties file missing." \
                "server.properties not found at $PROPERTIES_FILE. Skipping auto-config."
fi