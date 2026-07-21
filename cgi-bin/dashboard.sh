#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/colors.sh"

AGENT=$(get_user_agent)
PROTO="${HTTP_X_FORWARDED_PROTO:-http}"
HOST="${PROTO}://${HTTP_HOST:-localhost:8080}"

if [[ "$AGENT" == curl* ]]; then
    
    # --- curl ---#
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - DASHBOARD" "\"Terminal Dashboard Overview\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo ""
    echo " The full dashboard is best viewed in a web browser."
    echo " For terminal users, explore these dedicated endpoints:"
    echo ""
    echo "   ${BOLD_GREEN}curl${RESET} ${BLUE}${HOST}/cgi-bin/welcome.sh${RESET} ${WHITE}(Welcome & Main Menu)${RESET}"
    echo "   ${BOLD_GREEN}curl${RESET} ${BLUE}${HOST}/cgi-bin/status.sh${RESET}  ${WHITE}(Server Status & Vitals)${RESET}"
    echo "   ${BOLD_GREEN}curl${RESET} ${BLUE}${HOST}/cgi-bin/top.sh${RESET}     ${WHITE}(Live Top Processes)${RESET}"
    echo "   ${BOLD_GREEN}curl${RESET} ${BLUE}${HOST}/cgi-bin/docker.sh${RESET}  ${WHITE}(Docker Containers)${RESET}"
    echo "   ${BOLD_GREEN}curl${RESET} ${BLUE}${HOST}/cgi-bin/joke.sh${RESET}    ${WHITE}(Random Dad Joke)${RESET}"
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    
else

    # --- BROWSER MODE ---#
    render_header "ASH Dashboard"
    render_page "dashboard.html"
    render_footer

fi
