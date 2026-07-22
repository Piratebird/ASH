#!/usr/bin/env bash

# =============================================================================
# scan.sh - CLIENT SCAN DATA RECEIVER & VIEWER
# =============================================================================
#
# WHAT THIS BS DOES:
# Handles two HTTP methods:
#
#   GET  - Displays all stored client scan results as a dashboard.
#          Browsers get HTML, curl gets plain text (content negotiation).
#
#   POST - Receives JSON from the agent script running on client machines.
#          Saves each client's data to data/<client_ip>.json.
#          Overwrites the file if the same IP scans again (latest wins).
#
# DATA FLOW:
#   1. Client runs: curl -s http://server/cgi-bin/agent.sh | bash
#   2. Agent script collects client info and POSTs JSON to this endpoint
#   3. This script saves the JSON to data/<client_ip>.json
#   4. GET /cgi-bin/scan.sh shows all saved results
#
# STORAGE:
#   Files are stored in ../data/ (relative to cgi-bin/).
#   Each file is named after the client's IP address.
#   Files are plain JSON - you can read them manually.
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

# Path to the data directory (one level up from cgi-bin/)
DATA_DIR="$(dirname "${BASH_SOURCE[0]}")/../data"

# Ensure the data directory exists
mkdir -p "$DATA_DIR"


# =============================================================================
# HELPER: Extract a value from a simple JSON object using grep/sed (maybe add ripgrep in future idk)
# =============================================================================
# This is a dumb JSON parser - it just finds "key": "value" patterns.
# It won't work for nested objects or arrays, but it's fine for our flat
# JSON structure. It avoids requiring jq to be installed so hell yeah.
#
# Usage: show_field 'key_name' '/path/to/file.json'
# =============================================================================

show_field() {
    local key="$1"
    local file="$2"
    grep "\"${key}\"" "$file" 2>/dev/null | \
    sed "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"//" | \
    sed 's/".*//'
}


# GET HANDLER (Display all client scan results) ---#
handle_get() {
    AGENT=$(get_user_agent)
    PROTO="${HTTP_X_FORWARDED_PROTO:-http}"
    HOST="${PROTO}://${HTTP_HOST:-YOUR_SERVER}"
    HOST_ESCAPED=$(echo "$HOST" | html_escape)
    
    CLIENT_IP=$(get_real_ip)
    SAFE_IP=$(echo "$CLIENT_IP" | tr -cd 'a-zA-Z0-9.:-')
    FILE="${DATA_DIR}/${SAFE_IP}.json"
    
    if [[ "$AGENT" == curl* ]]; then
        # --- Plain text output for curl users ---
        send_200_text
        
        echo ""
        echo "${BOLD_WHITE}===========================================================${RESET}"
        print_logo "ASH - MY SCAN" "\"Remote Machine Data\"" ""
        echo "${BOLD_WHITE}===========================================================${RESET}"
        echo ""
        
        if [ ! -f "$FILE" ]; then
            echo "  ${BOLD_RED}No scan recorded for your IP (${CLIENT_IP}) yet.${RESET}"
            echo ""
            echo "  ${BOLD_PURPLE}To scan your machine, run:${RESET}"
            echo "    curl -sL ${HOST}/cgi-bin/agent.sh | bash"
            echo ""
        else
            echo "  ${BOLD_CYAN}Your IP${RESET}     : ${WHITE}${CLIENT_IP}${RESET}"
            echo "  ${BOLD_CYAN}User${RESET}        : ${WHITE}$(show_field 'user' "$FILE")${RESET}"
            echo "  ${BOLD_CYAN}Hostname${RESET}    : ${WHITE}$(show_field 'hostname' "$FILE")${RESET}"
            echo "  ${BOLD_CYAN}OS${RESET}          : ${WHITE}$(show_field 'os' "$FILE")${RESET}"
            echo "  ${BOLD_CYAN}Home Disk${RESET}   : ${WHITE}$(show_field 'disk_home' "$FILE")${RESET}"
            echo "  ${BOLD_CYAN}Storage${RESET}     : ${WHITE}$(show_field 'storage' "$FILE")${RESET}"
            echo "  ${BOLD_CYAN}Memory${RESET}      : ${WHITE}$(show_field 'memory' "$FILE")${RESET}"
            echo "  ${BOLD_CYAN}Scan Time${RESET}   : ${WHITE}$(show_field 'scan_time' "$FILE")${RESET}"
            echo ""
        fi
        echo "${BOLD_WHITE}===========================================================${RESET}"
        
    else
        # --- HTML output for browsers --- #
        render_header "My Scan"
        
        cat <<EOF
<div class="card section" style="margin-bottom: 20px;">
    <div class="card-label" style="display: flex; justify-content: space-between;">
        <span>Your Scan Results</span>
        <span style="color: var(--teal); font-size: 0.8em;">Data Source: agent.sh</span>
    </div>
EOF
        
        if [ ! -f "$FILE" ]; then
            cat <<EOF
    <div style="text-align: center; color: var(--subtext0); padding: 20px;">
        <p>No scan recorded for your IP (${CLIENT_IP}) yet.</p>
        <p>To scan your machine, run:</p>
        <pre style="background: var(--surface0); padding: 10px; border-radius: 6px; color: var(--text); display: inline-block; margin-top: 10px; max-width: 100%; overflow-x: auto;"><code>curl -sL ${HOST_ESCAPED}/cgi-bin/agent.sh | bash</code></pre>
    </div>
EOF
        else
            # SECURITY FIX: Pipe every user-submitted field through html_escape
            # to prevent attackers from injecting <script> tags into the JSON.
            cat <<EOF
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 15px;">
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">Your IP</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">${CLIENT_IP}</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">User</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'user' "$FILE" | html_escape)</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">Hostname</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'hostname' "$FILE" | html_escape)</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">OS</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'os' "$FILE" | html_escape)</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">Home Disk</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'disk_home' "$FILE" | html_escape)</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">Storage (/)</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'storage' "$FILE" | html_escape)</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">Memory</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'memory' "$FILE" | html_escape)</div>
        </div>
        <div style="background: var(--surface0); padding: 10px; border-radius: 6px;">
            <div style="font-size: 0.8em; color: var(--subtext0);">Scan Time</div>
            <div style="font-family: monospace; color: var(--text); margin-top: 4px; word-break: break-all;">$(show_field 'scan_time' "$FILE" | html_escape)</div>
        </div>
    </div>
EOF
        fi
        
        cat <<EOF
</div>
EOF
        
        render_footer
    fi
}


#--- POST HANDLER (Receive and store client scan data) ---#
handle_post() {
    # 1 Reject non-POST requests
    if [[ "$REQUEST_METHOD" != "POST" ]]; then
        send_400
        exit 0
    fi
    
    # 2. SECURITY: Read a MAXIMUM of 10KB.
    PAYLOAD=$(head -c 10000)
    
    #  SECURITY: Basic JSON validation. Does it start with '{'?
    if [[ ! "$PAYLOAD" =~ ^\{ ]]; then
        send_400
        exit 0
    fi
    
    # 4. Get the client IP and sanitize it (prevent path traversal like ../../etc/passwd)
    CLIENT_IP=$(get_real_ip)
    SAFE_IP=$(echo "$CLIENT_IP" | tr -cd 'a-zA-Z0-9.:-')
    
    # 5. Save the JSON file
    echo "$PAYLOAD" > "${DATA_DIR}/${SAFE_IP}.json"
    
    # Return a success message
    send_200_text
    echo "Data successfully received and saved as ${SAFE_IP}.json"
}

# ROUTING: Check the HTTP method and call the right handler
# This MUST come after the function definitions, otherwise bash won't
# recognize the function names when it tries to call them.
METHOD="${REQUEST_METHOD:-GET}"

case "$METHOD" in
    GET)
        handle_get
    ;;
    POST)
        handle_post
    ;;
    *)
        send_400
        echo "Only GET and POST are supported."
    ;;
esac
