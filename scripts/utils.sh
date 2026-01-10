#!/bin/bash

# --- Colors & Formatting ---
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Symbols ---
# Using :- fallbacks even for internal symbols for ultimate safety
SYM_OK="${GREEN}✔${NC}"
SYM_FAIL="${RED}✘${NC}"
SYM_WARN="${YELLOW}⚠${NC}"

log_section() {
    echo -e "\n${BOLD}${CYAN}SECTION:${NC} ${BOLD}${1:-}${NC}"
}

log_step() {
    printf "  ${NC}%-35s" "${1:-}..."
}

log_success() {
    echo -e "[ ${GREEN}OK${NC} ] ${SYM_OK}"
}

log_warning() {
    echo -e "[ ${YELLOW}WARN${NC} ] ${SYM_WARN}"
    echo -e "      ${YELLOW}↳ Note:${NC}  ${1:-}"
    if [ -n "${2:-}" ]; then
        echo -e "      ${DIM}↳ Suggestion: ${2}${NC}"
    fi
}

log_error() {
    echo -e "[ ${RED}FAIL${NC} ] ${SYM_FAIL}"
    echo -e "      ${RED}↳ Error:${NC} ${1:-}"
    if [ -n "${2:-}" ]; then
        echo -e "      ${DIM}↳ Hint:   ${2}${NC}"
    fi
}