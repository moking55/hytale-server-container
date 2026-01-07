#!/bin/sh
set -eu

# ==============================================================================
# network-check.sh for Hytale
# Optimized for Hytale's UDP/QUIC protocol and Docker networking
# ==============================================================================

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

log() {
    printf "%b[network-check] %s%b\n" "${2:-$RESET}" "$1" "$RESET"
}

# Defaults
SERVER_PORT="${SERVER_PORT:-25565}"
SERVER_IP="${SERVER_IP:-0.0.0.0}"

# 1. SERVER_PORT Validation
if [ -n "$SERVER_PORT" ]; then
    if ! echo "$SERVER_PORT" | grep -Eq '^[0-9]+$' || [ "$SERVER_PORT" -lt 1 ] || [ "$SERVER_PORT" -gt 65535 ]; then
        log "Warning: SERVER_PORT '$SERVER_PORT' is invalid (1-65535)." "$YELLOW"
    else
        log "Configuration: Port $SERVER_PORT is valid." "$GREEN"
    fi
fi

# 2. UDP vs TCP Check (Important for Hytale)
# Since the server isn't running yet, we check if the PORT is ALREADY in use
# by another process (which would cause a crash).
if ss -ulpn | grep -q ":$SERVER_PORT "; then
    log "CRITICAL: Port $SERVER_PORT is ALREADY in use by another process!" "$RED"
    # We don't exit 1 because this is usually a debug check, but it's a major warning.
else
    log "Environment: Port $SERVER_PORT is available for binding." "$GREEN"
fi

# 5. QUIC / UDP Kernel Capability Check
# QUIC requires large UDP buffers to avoid packet loss
RMEM_PATH="/proc/sys/net/core/rmem_max"
WMEM_PATH="/proc/sys/net/core/wmem_max"

if [ -r "$RMEM_PATH" ] && [ -r "$WMEM_PATH" ]; then
    RMEM_MAX=$(cat "$RMEM_PATH")
    WMEM_MAX=$(cat "$WMEM_PATH")

    if [ "$RMEM_MAX" -lt 2097152 ] || [ "$WMEM_MAX" -lt 2097152 ]; then
        log "Warning: UDP buffers are small (rmem=$RMEM_MAX, wmem=$WMEM_MAX). QUIC may suffer packet loss." "$YELLOW"
    else
        log "QUIC: UDP buffers are optimized (rmem=$RMEM_MAX, wmem=$WMEM_MAX)." "$GREEN"
    fi
else
    log "Warning: Cannot read UDP buffer limits. Kernel access restricted." "$YELLOW"
fi

# 3. DNS / Connectivity Check
# Check if the container can actually reach the internet (for Auth/Updates)
if curl -s --connect-timeout 5 https://google.com > /dev/null; then
    log "Connectivity: Internet access verified." "$GREEN"
    
    # External Reachability (UDP Check)
    # Note: Scanning your own public IP for a UDP port from inside a container 
    # often fails due to NAT hairpinning, so we treat this as a light hint.
    PUBLIC_IP=$(curl -s --connect-timeout 5 https://api.ipify.org)
    log "Public IP detected as: $PUBLIC_IP" "$GREEN"
else
    log "Warning: No internet access detected. Authentication may fail." "$YELLOW"
fi

# 4. SERVER_IP Syntax Validation (sh compatible)
is_valid_ipv4() {
    echo "$1" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || return 1
}

if [ -n "$SERVER_IP" ]; then
    if is_valid_ipv4 "$SERVER_IP" || echo "$SERVER_IP" | grep -Eq '^(([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,})$' || [ "$SERVER_IP" = "host.docker.internal" ]; then
        log "Configuration: SERVER_IP '$SERVER_IP' is valid." "$GREEN"
    else
        log "Warning: SERVER_IP '$SERVER_IP' looks invalid." "$YELLOW"
    fi
fi

log "Network checks finished." "$GREEN"
exit 0