#!/bin/sh
set -eu

# ==============================================================================
# SETUP USER (Alpine Pterodactyl Compatible)
# ==============================================================================

log() { echo "[setup-user] $*"; }

log "Starting Alpine setup-user script..."

# 1. Clean up existing users (Optional)
# ------------------------------------------------------------------------------
# Alpine usually has a 'guest' user (UID 405), but rarely 'ubuntu'.
for u in ubuntu node guest; do
    if id "$u" >/dev/null 2>&1; then
        log "Removing default user '$u'..."
        deluser "$u"
    fi
done

# 2. Create Group
# ------------------------------------------------------------------------------
if ! getent group "$GID" >/dev/null 2>&1; then
    log "Creating group '$USER' with GID=$GID..."
    # Alpine addgroup syntax: -g GID NAME
    addgroup -g "$GID" "$USER"
else
    log "Group with GID=$GID already exists"
fi

# 3. Create User
# ------------------------------------------------------------------------------
if ! id "$USER" >/dev/null 2>&1; then
    log "Creating user '$USER' with UID=$UID and HOME=$HOME..."
    
    # Alpine adduser syntax:
    # -u: UID
    # -G: Group
    # -h: Home directory
    # -s: Shell (/bin/sh is safest for Alpine, or /bin/bash if installed)
    # -D: Don't assign a password
    adduser -u "$UID" -G "$USER" -h "$HOME" -s /bin/sh -D "$USER"
else
    log "User '$USER' already exists"
fi

# 4. Permissions
# ------------------------------------------------------------------------------
log "Ensuring $HOME directory exists and has correct ownership..."
mkdir -p "$HOME"
chown -R "$USER":"$USER" "$HOME"

log "setup-user script finished successfully!"