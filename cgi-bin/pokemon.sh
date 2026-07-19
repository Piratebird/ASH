#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

AGENT=$(get_user_agent)

if [[ "$AGENT" == curl* ]]; then
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - POKEDEX" "\"Gotta Catch 'Em All\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo ""
    echo "  ${BOLD_YELLOW}#001${RESET} ${BOLD_BLUE}Topmon${RESET}      - ${WHITE}System Process Scanner${RESET}"
    echo "  ${BOLD_YELLOW}#002${RESET} ${BOLD_CYAN}Diskomon${RESET}    - ${WHITE}Storage Analyst${RESET}"
    echo "  ${BOLD_YELLOW}#003${RESET} ${BOLD_GREEN}Dockermon${RESET}   - ${WHITE}Container Watcher${RESET}"
    echo ""
    echo "  ${BOLD_PURPLE}View in browser for the full HTML experience!${RESET}"
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
else
    render_header "Pokemon Cards"
    render_page "pokemon.html"
    render_footer
fi
