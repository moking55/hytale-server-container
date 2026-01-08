#!/bin/sh
set -eu

# Load dependencies
. "$(dirname "$0")/../utils.sh"
. "$(dirname "$0")/lib/network_logic.sh"

log "Starting network configuration audit..." "$BLUE" "network-check"

validate_port_cfg
validate_ip_syntax
check_port_availability
check_udp_stack
check_connectivity

log "Network audit finished." "$GREEN" "network-check"
exit 0