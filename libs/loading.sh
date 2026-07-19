#!/usr/bin/env bash

# ANSI Escape Sequences for terminal colors (we source colors.sh if not sourced)
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

start_loading() {
    # Hide cursor
    echo -ne "\e[?25l"
    
    # Start the loading animation in the background
    (
        local width=20
        local block_size=6
        local pos=0
        local direction=1
        
        while true; do
            local bar=""
            for ((j=0; j<width; j++)); do
                if (( j >= pos && j < pos + block_size )); then
                    bar+="#"
                else
                    bar+="="
                fi
            done
            
            echo -ne "\r${BOLD_CYAN}[${bar}] Fetching data...${RESET}"
            
            pos=$((pos + direction))
            if (( pos <= 0 || pos >= width - block_size )); then
                direction=$((direction * -1))
            fi
            sleep 0.1
        done
    ) &
    export LOADING_PID=$!
}

stop_loading() {
    if [[ -n "$LOADING_PID" ]]; then
        kill $LOADING_PID 2>/dev/null
        wait $LOADING_PID 2>/dev/null
        # Clear the loading line and show cursor
        echo -ne "\r\e[K\e[?25h"
    fi
}

draw_progress() {
    local percent=$1
    local label=$2
    local width=20
    
    # Truncate label to prevent terminal wrapping which breaks \r
    local max_len=35
    if [ ${#label} -gt $max_len ]; then
        label="${label:0:$((max_len-3))}..."
    fi
    
    local filled=$(( percent * width / 100 ))
    local bar_filled=""
    local bar_empty=""
    
    for ((i=0; i<width; i++)); do
        if (( i < filled )); then
            bar_filled+="#"
        else
            bar_empty+="="
        fi
    done
    
    # \e[K clears the rest of the line
    echo -ne "\r\e[K${BOLD_WHITE}[${BOLD_GREEN}${bar_filled}${WHITE}${bar_empty}${BOLD_WHITE}] ${BOLD_CYAN}${percent}%${RESET} ${label}"
}
