#!/bin/sh
set -eu

# Load dependencies
. "$(dirname "$0")/../utils.sh"
. "$(dirname "$0")/lib/security_logic.sh"

# Execute
log "Starting security audit..." "$BLUE"

check_integrity
check_container_hardening
check_clock_sync

log "Security audit finished." "$GREEN"