#!/usr/bin/env bash
# i hated this file so fucking much yo

# =============================================================================
# agent.sh - CLIENT SYSTEM SCANNER
# =============================================================================
#
# WHAT THIS DOES:
# Returns a Bash script as plain text. When a client runs:
#
#   curl -sL https://YOUR_SERVER/cgi-bin/agent.sh | bash
#
# The script runs on THEIR machine, collects their system info,
# and POSTs it back to the server via /cgi-bin/scan.sh.
#
# HOW THE TRICK WORKS:
# The script is output in TWO parts:
#
#   Part 1 (unquoted heredoc <<EOF): Expands $SERVER_HOST so the client
#   knows the real server address to POST back to.
#
#   Part 2 (quoted heredoc <<'EOF'): Sends everything as literal text.
#   Variables like $USER, $HOSTNAME, $HOME are NOT expanded by the server.
#   They get expanded by the CLIENT's bash when they run the script.
#
# This two-part approach is how we inject the server address while keeping
# all client-side variables intact.
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"

# Send plain text headers - we're returning a script, not HTML.
send_200_text

# HTTP_HOST is a CGI env var containing the host:port the client connected to.
# We'll inject this into the script so the client knows where to POST back to.
PROTO="${HTTP_X_FORWARDED_PROTO:-http}"
SERVER_HOST="${PROTO}://${HTTP_HOST:-localhost:8080}"

# ===========================================================================
# PART 1: Unquoted heredoc - variables ARE expanded by the server
# ===========================================================================
# Only the SERVER= line needs the real address. Everything else in this
# block is just the script header and the server variable assignment.
# ===========================================================================
cat << EOF
#!/usr/bin/env bash
# ASH Client Scanner - collects your system info and sends it to the server.
SERVER="${SERVER_HOST}"

$(cat "$(dirname "${BASH_SOURCE[0]}")/../libs/colors.sh")
EOF
# That's it for Part 1. Short and sweet - just sets the SERVER variable.

# ===========================================================================
# PART 2: Quoted heredoc - variables are NOT expanded, sent as-is
# ===========================================================================
# Everything below is sent as literal text to the client.
# $USER, $HOSTNAME, $HOME, etc. will only be expanded when the client
# runs this script on their own machine.
#
# BUT the SERVER= variable from Part 1 WILL work because the client's
# bash sees it when the full script runs.
# ===========================================================================
cat << 'EOF'

# Build the URL to POST back to using the SERVER variable from above.
SCAN_URL="${SERVER}/cgi-bin/scan.sh"

echo ""
echo "${BOLD_WHITE}===========================================================${RESET}"
echo "${BOLD_CYAN}   ░███      ░██████   ░██     ░██ ${RESET}      ASH - SCANNER"
echo "${BOLD_CYAN}  ░██░██    ░██   ░██  ░██     ░██ ${RESET}      Built by piratebird"
echo "${BOLD_CYAN} ░██  ░██  ░██         ░██     ░██ ${RESET}"
echo "${BOLD_CYAN}░█████████  ░████████  ░██████████ ${RESET}      \"Remote System Collector\""
echo "${BOLD_CYAN}░██    ░██         ░██ ░██     ░██ ${RESET}"
echo "${BOLD_CYAN}░██    ░██  ░██   ░██  ░██     ░██ ${RESET}"
echo "${BOLD_CYAN}░██    ░██   ░██████   ░██     ░██ ${RESET}"
echo "${BOLD_WHITE}===========================================================${RESET}"
echo ""

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
    
    echo -ne "\r\e[K${BOLD_WHITE}[${BOLD_GREEN}${bar_filled}${WHITE}${bar_empty}${BOLD_WHITE}] ${BOLD_CYAN}${percent}%${RESET} ${label}"
}

# --- STEP 1: Collect system information ---
# These are all CLIENT-side variables. They capture info from the
# machine running this script, not the server.

echo -ne "\e[?25l" # Hide cursor

draw_progress 10 "Fetching user & host..."
CLIENT_USER="${USER:-$(whoami)}"
CLIENT_HOST="${HOSTNAME:-$(hostname)}"
sleep 0.1

draw_progress 25 "Fetching OS info..."
CLIENT_OS="$(uname -sm)"
sleep 0.1

draw_progress 40 "Calculating home disk usage..."
CLIENT_DISK="$(du -sh "$HOME" 2>/dev/null | head -n 1)"

draw_progress 60 "Checking root storage..."
CLIENT_STORAGE="$(df -h / 2>/dev/null | tail -n 1)"
sleep 0.1

draw_progress 80 "Fetching top processes..."
CLIENT_PROCS="$(ps -eo pcpu,pid,comm 2>/dev/null | sort -k 1 -nr | head -n 4)"
sleep 0.1

draw_progress 90 "Fetching memory stats..."
CLIENT_MEM="$(free -h 2>/dev/null | grep Mem || echo "N/A (macOS?)")"
CLIENT_TIME="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

draw_progress 100 "Collection complete!"
echo -ne "\e[?25h\n\n" # Show cursor and newline

# Print the collected info to the user's terminal so they can see it
echo "${BOLD_BLUE}User        :${RESET} ${WHITE}${CLIENT_USER}${RESET}"
echo "${BOLD_BLUE}Hostname    :${RESET} ${WHITE}${CLIENT_HOST}${RESET}"
echo "${BOLD_BLUE}OS          :${RESET} ${WHITE}${CLIENT_OS}${RESET}"
echo "${BOLD_BLUE}Home Disk   :${RESET} ${WHITE}${CLIENT_DISK}${RESET}"
echo "${BOLD_BLUE}Storage     :${RESET} ${WHITE}${CLIENT_STORAGE}${RESET}"
echo "${BOLD_BLUE}Memory      :${RESET} ${WHITE}${CLIENT_MEM}${RESET}"
echo ""
echo "${BOLD_PURPLE}--- Top Processes ---${RESET}"
echo "${WHITE}${CLIENT_PROCS}${RESET}"
echo ""

# --- STEP 2: Build JSON payload ---
# Bash has no built-in JSON support, so we construct it manually.
# NOTE: json_escape is intentionally duplicated here (also in libs/http.sh)
# because this script runs on the CLIENT's machine, not the server.
# The client won't have access to our libs/ directory.
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/}"
    echo -n "$s"
}

PAYLOAD=$(cat <<PAYLOAD_EOF
{
    "user": "$(json_escape "${CLIENT_USER}")",
    "hostname": "$(json_escape "${CLIENT_HOST}")",
    "os": "$(json_escape "${CLIENT_OS}")",
    "disk_home": "$(json_escape "${CLIENT_DISK}")",
    "storage": "$(json_escape "${CLIENT_STORAGE}")",
    "memory": "$(json_escape "${CLIENT_MEM}")",
    "processes": "$(json_escape "${CLIENT_PROCS}")",
    "scan_time": "$(json_escape "${CLIENT_TIME}")"
}
PAYLOAD_EOF
)

echo "${BOLD_YELLOW}--- JSON Payload (for debugging) ---${RESET}"
echo "${WHITE}${PAYLOAD}${RESET}"
echo ""

# --- STEP 3: POST the data to the server ---
# curl sends the JSON payload to the server's scan.sh endpoint.
# -s = silent (no progress bar)
# -w "\n%{http_code}" = append the HTTP status code to output (on last line)
# -X POST = use POST method
# -H = set Content-Type header so server knows it's JSON
# -d = the request body (our JSON payload)

echo "${CYAN}Sending scan data to ${SERVER}...${RESET}"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}" \
    "${SCAN_URL}" 2>/dev/null)

# Split response: last line is the HTTP code, everything else is the body
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "${BOLD_GREEN}Scan saved successfully! Your data is now in the container (technically not a server, but it reads it, so whatever).${RESET}"
else
    echo "${BOLD_RED}Warning: Server returned HTTP ${HTTP_CODE}${RESET}"
    echo "Response: ${BODY}"
    echo "Your system info was still printed above."
fi

echo ""
echo "${BOLD_WHITE}========================================${RESET}"
echo ""
EOF
