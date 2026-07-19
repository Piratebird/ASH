#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

# CGI environments typically clear the $HOME variable.
# We must explicitly look up the home directory of the user running the script.
if [ -z "$HOME" ]; then
    HOME=$(getent passwd "$(whoami)" | cut -d: -f6)
fi
PROJECT_ROOT="${HOME:-/home/$(whoami)}"

# Fallback to root (/) if the home directory doesn't exist or is empty
if [ ! -d "$PROJECT_ROOT" ] || [ -z "$(ls -A "$PROJECT_ROOT" 2>/dev/null)" ]; then
    PROJECT_ROOT="/"
fi

AGENT=$(get_user_agent)

if [[ "$AGENT" == curl* ]]; then
    # --- curl ---#
    # Send headers immediately so curl knows response started
    send_200_text
    
    # Source loading functionality
    source "$(dirname "${BASH_SOURCE[0]}")/../libs/loading.sh"
    
    echo -ne "\e[?25l" # Hide cursor
    
    shopt -s dotglob nullglob
    items=("$PROJECT_ROOT"/*)
    total=${#items[@]}
    current=0
    raw_output=""
    
    for item in "${items[@]}"; do
        if [ "$total" -gt 0 ]; then
            percent=$(( current * 100 / total ))
            draw_progress "$percent" "Scanning $(basename "$item")..."
        fi
        
        res=$(du -sh "$item" 2>/dev/null)
        if [ -n "$res" ]; then
            raw_output+="$res\n"
        fi
        
        current=$((current + 1))
    done
    
    draw_progress 100 "Done! Sorting..."
    
    DISK_USAGE=$(echo -e "$raw_output" | sort -hr | head -n 20 | html_escape)
    export DISK_USAGE PROJECT_ROOT
    
    # clear loading bar and show cursor
    echo -ne "\r\e[K\e[?25h"
    
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - DU" "\"Storage Analyst\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo -e "${DISK_USAGE}"
    echo "${BOLD_WHITE}===========================================================${RESET}"
    
else
    # --- BROWSER MODE --- #
    # Run du without loading bar (browser handles page load UI)
    DISK_USAGE=$(du -sh "$PROJECT_ROOT"/* 2>/dev/null | sort -hr | head -n 20 | html_escape)
    export DISK_USAGE PROJECT_ROOT
    
    render_header "Disk Usage"
    render_page "du.html" '${PROJECT_ROOT} ${DISK_USAGE}'
    render_footer
fi
