#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

if command -v docker &> /dev/null; then
    # 2>&1 ensures that if there is a permission error (example cannot connect to docker daemon),
    # the error message is captured instead of disappearing into the void.
    DOCKER_OUT=$(docker ps -a 2>&1 | html_escape)
else
    DOCKER_OUT="Docker is not installed. Please install Docker to use this endpoint."
fi

export DOCKER_OUT

AGENT=$(get_user_agent)

if [[ "$AGENT" == curl* ]]; then
    
    # --- curl ---#
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - DOCKER" "\"Container Watcher\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo -e "${DOCKER_OUT}"

else

    # --- BROWSER MODE (HTML) ---
    render_header "Docker Containers"
    render_page "docker.html" '${DOCKER_OUT}'
    render_footer

fi
