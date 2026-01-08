#!/bin/sh

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Centralized Log Function
# Usage: log "message" "color" "prefix"
log() {
    local msg="$1"
    local color="${2:-$RESET}"
    local prefix="${3:-docker-hytale-server}" # Changed default from security-check to hytale
    
    # Use printf for better cross-shell compatibility
    printf "%b[%s] %s%b\n" "$color" "$prefix" "$msg" "$RESET"
}