#!/bin/sh
set -eu

# Load dependencies (Ensuring SCRIPTS_PATH is available from the parent)
. "$SCRIPTS_PATH/utils.sh"

log_section "JVM Flag Management"

# =============================================================================
# JVM FLAGS (go BEFORE -jar)
# These are actual Java VM options
# =============================================================================
export HYTALE_CACHE_FLAG=""
export HYTALE_QUIET_FLAGS=""

# 1. AOT Cache Configuration (valid JVM flag)
log_step "AOT Cache"
if [ "${CACHE:-}" = "TRUE" ]; then
    export HYTALE_CACHE_FLAG="-XX:AOTCache=HytaleServer.aot"
    log_success
else
    printf "${DIM}skipped${NC}\n"
fi

# 2. Debug & Quiet Mode Logic (valid JVM flags)
log_step "Quiet Mode"
if [ "${DEBUG:-FALSE}" = "FALSE" ]; then
    # Disable OOM Dumps and suppress fatal error messages for a cleaner production environment
    export HYTALE_QUIET_FLAGS="-XX:-HeapDumpOnOutOfMemoryError -XX:+SuppressFatalErrorMessage"
    log_success
else
    printf "${DIM}disabled (Debug Active)${NC}\n"
fi

# =============================================================================
# CLI ARGUMENTS (go AFTER -jar and the JAR path)
# These are Hytale server command-line arguments
# =============================================================================
export HYTALE_AUTH_MODE_ARG=""
export HYTALE_ALLOW_OP_ARG=""
export HYTALE_BACKUP_ARG=""

# 3. Authentication Mode
# Valid values: authenticated, offline (default: authenticated if not set)
log_step "Auth Mode"
case "${HYTALE_AUTH_MODE:-}" in
    authenticated|AUTHENTICATED)
        export HYTALE_AUTH_MODE_ARG="--auth-mode authenticated"
        printf "${GREEN}authenticated${NC}\n"
        ;;
    offline|OFFLINE|FALSE)
        export HYTALE_AUTH_MODE_ARG="--auth-mode offline"
        printf "${YELLOW}offline${NC}\n"
        ;;
    TRUE)
        # Backward compatibility: TRUE now means authenticated
        export HYTALE_AUTH_MODE_ARG="--auth-mode authenticated"
        printf "${GREEN}authenticated${NC} ${DIM}(migrated from TRUE)${NC}\n"
        ;;
    *)
        # Default: don't pass the flag, let server use its default (authenticated)
        export HYTALE_AUTH_MODE_ARG=""
        printf "${DIM}default${NC}\n"
        ;;
esac

# 4. Operator Permissions (CLI argument)
log_step "Allow OP"
if [ "${HYTALE_ALLOW_OP:-}" = "TRUE" ]; then
    export HYTALE_ALLOW_OP_ARG="--allow-op"
    log_success
else
    printf "${DIM}disabled${NC}\n"
fi

# 5. Backup System (CLI arguments)
log_step "Server Backups"
if [ "${HYTALE_BACKUP:-}" = "TRUE" ]; then
    export HYTALE_BACKUP_ARG="--backup"
    
    # Add backup frequency if specified
    if [ -n "${HYTALE_BACKUP_FREQUENCY:-}" ]; then
        export HYTALE_BACKUP_ARG="$HYTALE_BACKUP_ARG --backup-frequency $HYTALE_BACKUP_FREQUENCY"
        printf "${GREEN}enabled${NC} (${CYAN}every ${HYTALE_BACKUP_FREQUENCY} min${NC})\n"
    else
        log_success
    fi
    
    # Add backup directory if specified
    if [ -n "${HYTALE_BACKUP_DIR:-}" ]; then
        export HYTALE_BACKUP_ARG="$HYTALE_BACKUP_ARG --backup-dir $HYTALE_BACKUP_DIR"
    fi
else
    printf "${DIM}disabled${NC}\n"
fi

printf "      ${DIM}↳ Configuration:${NC} ${GREEN}Ready${NC}\n"