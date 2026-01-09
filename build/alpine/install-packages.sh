#!/bin/sh
set -eu

# ==============================================================================
# INSTALL PACKAGES (Alpine)
# Installs runtime dependencies using apk
# ==============================================================================

# Colors
BLUE="\033[0;34m"
GREEN="\033[0;32m"
RESET="\033[0m"

log() {
    printf "%b[install-packages] %s%b\n" "${2:-$BLUE}" "$1" "$RESET"
}

# 1. Update and Upgrade
# ------------------------------------------------------------------------------
log "Updating APK index..."
apk update
apk upgrade

# 2. Install Dependencies
# ------------------------------------------------------------------------------
log "Installing required packages..."
# --no-cache avoids the need to run 'apk del' later as it doesn't store the index locally
apk add --no-cache \
    curl \
    ca-certificates \
    tini \
    dos2unix \
    jq \
    unzip \
    tzdata \
    iproute2-ss \
    bash \
    ${EXTRA_APK_PACKAGES:-}

# Note: 'iproute2-ss' provides the 'ss' command for healthchecks in Alpine.
# Note: 'bash' is added here to ensure your other scripts (if they use #!/bin/bash) still work.

# 3. Configuration
# ------------------------------------------------------------------------------
log "Configuring timezone..."
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone

# 4. Cleanup
# ------------------------------------------------------------------------------
# Alpine's --no-cache flag already handled the cleanup of the index.
# We just verify the scripts are executable.
log "Alpine package installation finished successfully!" "$GREEN"