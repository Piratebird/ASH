#!/usr/bin/env bash
# the client for this goofy project

# Source the libs
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

# data to sell to evil goverments and corporations
METHOD="$(echo "${REQUEST_METHOD:-GET}" | html_escape)"
AGENT="$(get_user_agent | html_escape)"
IP="$(get_real_ip)"

# Collect network interface data
# Parse each interface: name, state, ipv4, ipv6, mac
build_network_html() {
    # local first=1

    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

        # Parse the brief output: name state addresses...
        local iface state
        iface=$(echo "$line" | awk '{print $1}' | sed 's/:$//' | html_escape)
        state=$(echo "$line" | awk '{print $2}' | html_escape)

        # Skip loopback
        [[ "$iface" == "lo" ]] && continue

        # Get all addresses (everything after state field)
        local addrs
        addrs=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i}')

        # IPv4 = addresses matching digits.digits.digits.digits/prefix
        local ipv4
        # regex the goat
        ipv4=$(echo "$addrs" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' | head -n1 | html_escape)

        # IPv6 = addresses with colons (must have at least one colon), skip link-local fe80::
        local ipv6
        ipv6=$(echo "$addrs" | grep -oP '[0-9a-f]*:[0-9a-f:]+/[0-9]+' | grep -v '^fe80' | head -n1 | html_escape)

        # Get MAC from ip link (not available in brief mode)
        local mac
        mac=$(ip link show "$iface" 2>/dev/null | awk '/link\/ether/ {print $2}' | html_escape)

        # Determine state class (UNKNOWN = tunnel/functional, treat as up)
        local state_class="net-down"
        [[ "$state" == "UP" || "$state" == "UNKNOWN" ]] && state_class="net-up"

        # Build the card
        cat <<IFACE
    <div class="net-card">
        <div class="net-header">
            <span class="net-dot ${state_class}"></span>
            <span class="net-name">${iface}</span>
            <span class="net-state ${state_class}">${state}</span>
        </div>
        <div class="net-details">
IFACE

        if [[ -n "$ipv4" ]]; then
            cat <<IFACE
            <div class="net-row">
                <span class="net-label">IPv4</span>
                <span class="net-value"><code>${ipv4}</code></span>
            </div>
IFACE
        fi

        if [[ -n "$ipv6" ]]; then
            cat <<IFACE
            <div class="net-row">
                <span class="net-label">IPv6</span>
                <span class="net-value"><code>${ipv6}</code></span>
            </div>
IFACE
        fi

        if [[ -n "$mac" ]]; then
            cat <<IFACE
            <div class="net-row">
                <span class="net-label">MAC</span>
                <span class="net-value"><code>${mac}</code></span>
            </div>
IFACE
        fi

        if [[ -z "$ipv4" && -z "$ipv6" ]]; then
            cat <<IFACE
            <div class="net-row">
                <span class="net-label">Info</span>
                <span class="net-value net-muted">No addresses assigned</span>
            </div>
IFACE
        fi

        cat <<IFACE
        </div>
    </div>
IFACE

    done <<< "$(ip -br a 2>/dev/null)"
}

# Are they using curl?
if [[ "$AGENT" == curl* ]]; then

    # Send Plain Text for Terminal
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - CLIENT" "\"Identity & Network Info\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo ""
    echo "${BOLD_YELLOW}==============================${RESET}"
    echo " ${BOLD_BLUE}Method${RESET}     : ${WHITE}$METHOD${RESET}"
    echo " ${BOLD_BLUE}IP Address${RESET} : ${WHITE}$IP${RESET}"
    echo " ${BOLD_BLUE}User-Agent${RESET} : ${WHITE}$AGENT${RESET}"
    echo "${BOLD_YELLOW}==============================${RESET}"
    echo ""
    echo "${BOLD_PURPLE}------- Network Interfaces -------${RESET}"
    ip -br a 2>/dev/null

else

    # Send HTML for Browsers
    render_header "Client Identity"

    cat <<EOF
<div class="card section">
    <div class="card-label">Request Info</div>
    <ul>
        <li><strong>Method:</strong> <code>${METHOD}</code></li>
        <li><strong>User-Agent:</strong> <code>${AGENT}</code></li>
        <li><strong>Real IP:</strong> <code>${IP}</code></li>
    </ul>
</div>

<div class="card section">
    <div class="card-label">Network Interfaces</div>
    <div class="net-grid">
EOF

    build_network_html

    cat <<EOF
    </div>
</div>
EOF

    render_footer

fi
