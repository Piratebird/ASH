#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

AGENT=$(get_user_agent)
CLIENT_IP=$(get_real_ip)
LANG="${HTTP_ACCEPT_LANGUAGE:-Unknown}"
ENCODING="${HTTP_ACCEPT_ENCODING:-Unknown}"
HOST="${HTTP_HOST:-localhost:8080}"

# Parse OS from User-Agent
parse_os() {
    local ua="$1"
    case "$ua" in
        *Android*)    echo "$ua" | grep -oP 'Android [\d.]+' ;;
        *iPhone*)     echo "$ua" | grep -oP 'OS [\d_]+' | tr '_' '.' ;;
        *Mac\ OS\ X*) echo "$ua" | grep -oP 'Mac OS X [\d._]+' | tr '_' '.' ;;
        *Windows\ NT\ 10*) echo "Windows 10/11" ;;
        *Linux*)      echo "Linux" ;;
        curl*)        echo "CLI (curl)" ;;
        *)            echo "Unknown" ;;
    esac
}

# Parse browser
parse_browser() {
    local ua="$1"
    case "$ua" in
        *Edg/*)    echo "$ua" | grep -oP 'Edg/[\d.]+' ;;
        *Chrome/*) echo "$ua" | grep -oP 'Chrome/[\d.]+' ;;
        *Safari/*) echo "Safari" ;;
        *Firefox/*) echo "$ua" | grep -oP 'Firefox/[\d.]+' ;;
        curl*)     echo "$ua" | grep -oP 'curl/[\d.]+' ;;
        *)         echo "Unknown" ;;
    esac
}

# Parse device type
parse_device_type() {
    local ua="$1"
    case "$ua" in
        *Mobile*|*Android*|*iPhone*) echo "Mobile" ;;
        *iPad*|*Tablet*)             echo "Tablet" ;;
        curl*|*Wget*|*HTTPie*)       echo "CLI" ;;
        *)                           echo "Desktop" ;;
    esac
}

OS=$(parse_os "$AGENT")
BROWSER=$(parse_browser "$AGENT")
DEVICE_TYPE=$(parse_device_type "$AGENT")

# Fix empty outputs
OS=${OS:-Unknown}
BROWSER=${BROWSER:-Unknown}

if [[ "$AGENT" == curl* ]]; then
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - DEVICE INFO" "\"Your Client Identity\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo ""
    echo "  ${BOLD_CYAN}IP Address${RESET}   : ${WHITE}${CLIENT_IP}${RESET}"
    echo "  ${BOLD_CYAN}Device Type${RESET}  : ${WHITE}${DEVICE_TYPE}${RESET}"
    echo "  ${BOLD_CYAN}OS${RESET}           : ${WHITE}${OS}${RESET}"
    echo "  ${BOLD_CYAN}Language${RESET}     : ${WHITE}${LANG%%,*}${RESET}"
    echo "  ${BOLD_CYAN}Encoding${RESET}     : ${WHITE}${ENCODING}${RESET}"
    echo ""
    echo "  ${BOLD_PURPLE}For full system info, run:${RESET}"
    echo "    curl -s http://${HOST}/cgi-bin/agent.sh | bash"
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
else
    # Export for template rendering
    export CLIENT_IP OS BROWSER DEVICE_TYPE LANG ENCODING
    
    render_header "Device Info"
    render_page "device_info.html" '${CLIENT_IP} ${OS} ${BROWSER} ${DEVICE_TYPE} ${LANG} ${ENCODING} ${HOST}'
    render_footer
fi
