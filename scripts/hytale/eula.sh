#!/bin/bash
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

log_section "Legal Agreements"

# EULA Check
case "${EULA:-false}" in
    [Tt][Rr][Uu][Ee])
        log_step "Accepting EULA"
        if echo "eula=true" > "${HOME}/eula.txt"; then
            log_success
        else
            log_error "Failed to write eula.txt" "Check folder permissions in ${HOME}."
            exit 1
        fi
    ;;
    *)
        log_step "Verifying EULA status"
        if [ ! -f "${HOME}/eula.txt" ] || ! grep -q "eula=true" "${HOME}/eula.txt"; then
            log_error "EULA not accepted." \
            "You must set the environment variable EULA=true to run this server."
            exit 1
        else
            log_success
        fi
    ;;
esac