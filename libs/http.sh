#!/usr/bin/env bash

###--- collecting information like pokemons ---###
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

get_method() {
    echo "${REQUEST_METHOD:-GET}"
}

# getting the user agent otherwise returning "Unknown"
get_user_agent() {
    echo "${HTTP_USER_AGENT:-"Unknown"}"
}


get_real_ip() {
    # If behind a proxy/Docker, try X-Forwarded-For first
    local ip="${HTTP_X_FORWARDED_FOR:-$REMOTE_ADDR}"
    # If multiple IPs are in X-Forwarded-For (e.g., "client, proxy1"), take the first one
    ip=$(echo "$ip" | awk -F, '{print $1}' | xargs)
    
    # Strip all non-IP characters for security
    echo "${ip:-127.0.0.1}" | tr -cd 'a-zA-Z0-9.:-'
}

html_escape() {
    # Replaces sensitive HTML characters with their safe entity equivalents
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'\''/\&#39;/g'
}

json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"   # escape backslashes
    s="${s//\"/\\\"}"   # escape quotes
    s="${s//$'\n'/\\n}" # escape newlines
    s="${s//$'\t'/\\t}" # escape tabs
    s="${s//$'\r'/}"    # remove carriage returns
    echo -n "$s"
}

# Print the giant ASH ascii logo
print_logo() {
    local title="${1:-ASH - API Server Engine}"
    local sub1="${2:-Built by piratebird (with a lot of agony and despair)}"
    
    local slogans=("\"Some call it spyware, I call it spaghetti\"" "\"Collecting data like pokemons\"")
    local rand_slogan="${slogans[$RANDOM % 2]}"
    local sub2="${3:-$rand_slogan}"
    
    echo "${BOLD_CYAN}   ░███      ░██████   ░██     ░██${RESET}      ${title}"
    echo "${BOLD_CYAN}  ░██░██    ░██   ░██  ░██     ░██${RESET}      ${sub1}"
    echo "${BOLD_CYAN} ░██  ░██  ░██         ░██     ░██${RESET}"
    echo "${BOLD_CYAN}░█████████  ░████████  ░██████████${RESET}      ${sub2}"
    echo "${BOLD_CYAN}░██    ░██         ░██ ░██     ░██${RESET}"
    echo "${BOLD_CYAN}░██    ░██  ░██   ░██  ░██     ░██${RESET}"
    echo "${BOLD_CYAN}░██    ░██   ░██████   ░██     ░██${RESET}"
}

###--- response helpers ---###
# note to self: CGI requires headers followed by exactly one empty line.

send_200_html() {
    echo "Status: 200 OK"
    echo "Content-Type: text/html; charset=utf-8"
    echo ""
}

send_200_json() {
    echo "Status: 200 OK"
    echo "Content-Type: application/json; charset=utf-8"
    echo ""
}

send_200_text() {
    echo "Status: 200 OK"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
}

# Redirects the client to a new URL
send_302_redirect() {
    local url="$1"
    echo "Status: 302 Found"
    echo "Location: $url"
    echo ""
}

send_404() {
    echo "Status: 404 Not Found"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
    echo "Error 404: Endpoint not found."
}

send_500() {
    echo "Status: 500 Internal Server Error"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
    echo "Error 500: Internal Server Error."
}

send_400() {
    echo "Status: 400 Bad Request"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
    echo "Error 400: Bad Request."
}

send_401() {
    echo "Status: 401 Unauthorized"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
    echo "Error 401: Unauthorized."
}