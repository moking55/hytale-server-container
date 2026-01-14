#!/bin/sh
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

# Use the log_section helper for consistent styling
log_section "Hytale Content Check"

# 1. Check if the server is already installed
log_step "Hytale Binary Check"

if [ ! -f "$SERVER_JAR_PATH" ]; then
    log_warning "HytaleServer.jar not found at $SERVER_JAR_PATH." \
    "Initializing first-time installation/extraction..."

    # Find the downloaded zip
    ZIP_FILE=$(ls "$BASE_DIR"/2026.01*.zip 2>/dev/null | head -n 1)
    
    # 2. Download if the zip is also missing
    if [ -z "$ZIP_FILE" ]; then
        log_step "Download Status"
        log_warning "No update package found. Running downloader..."
        hytale-downloader
        
        ZIP_FILE=$(ls "$BASE_DIR"/2026.01*.zip 2>/dev/null | head -n 1)
        
        if [ -z "$ZIP_FILE" ]; then
            log_error "Download failed." "Could not find a valid 2026.01*.zip after running downloader."
            exit 1
        fi
        log_success
    fi

    # 3. Extract with 7zip
    log_step "Extracting Game Content"
    # Replaced echo -e with printf for POSIX compatibility
    printf "      ${DIM}↳ Target:${NC} ${GREEN}%s${NC}\n" "$GAME_DIR"
    
    # x: eXtract with full paths
    # -aoa: Overwrite All existing files
    # -bsp1: Show progress percentage
    # -mmt=on: Full multi-core CPU performance
    # -o: Output directory
    if 7z x "$ZIP_FILE" -aoa -bsp1 -mmt=on -o"$GAME_DIR"; then
        log_success
    else
        log_error "Extraction failed" "Check disk space or 7z compatibility."
        exit 1
    fi

    # 4. Finalize
    log_step "Post-Extraction Cleanup"
    rm -f "$ZIP_FILE"
    log_success
    
    log_step "File Permissions"
    if chmod -R 755 "$GAME_DIR"; then
        log_success
    else
        log_warning "Chmod failed" "Permissions might need manual adjustment."
    fi
else
    log_success
    # Replaced echo -e with printf
    printf "      ${DIM}↳ Info:${NC} HytaleServer.jar exists. Skipping extraction.\n"
fi