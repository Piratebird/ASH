#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/colors.sh"

AGENT=$(get_user_agent)
HOST="${HTTP_HOST:-localhost:8080}"
HOST_ESCAPED=$(echo "$HOST" | html_escape)
export HOST HOST_ESCAPED

if [[ "$AGENT" == curl* ]]; then
    
    
    # --- curl ---#
    send_200_text
    
    echo ""
    print_logo
    echo ""
    
    cat << EOF
${BOLD_GREEN}┌─ About ──────────────────────────┐${RESET}
${BOLD_GREEN}│${RESET} ASH. A lightweight,              ${BOLD_GREEN}│${RESET}
${BOLD_GREEN}│${RESET} pure Bash CGI server providing   ${BOLD_GREEN}│${RESET}
${BOLD_GREEN}│${RESET} live system stats, process data, ${BOLD_GREEN}│${RESET}
${BOLD_GREEN}│${RESET} and remote client scanning.      ${BOLD_GREEN}│${RESET}
${BOLD_GREEN}│                                  │${RESET}
${BOLD_GREEN}└──────────────────────────────────┘${RESET}

 ${BOLD_YELLOW}Gobos${RESET} (completly did not steal the idea from ysap)

 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/dashboard.sh${RESET}   ${WHITE}Terminal Dashboard Overview${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/status.sh${RESET}      ${WHITE}Get JSON server status${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/client.sh${RESET}      ${WHITE}Get your client/network info${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/device_info.sh${RESET} ${WHITE}Get your local device specs${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/top.sh${RESET}         ${WHITE}View live top processes${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/docker.sh${RESET}      ${WHITE}View running Docker containers${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}-s ${HOST}/cgi-bin/du.sh${RESET}       ${WHITE}View home directory disk usage${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/joke.sh${RESET}        ${WHITE}Get a random Dad Joke${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/pokemon.sh${RESET}     ${WHITE}View ASH Pokemon Cards${RESET}
 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}${HOST}/cgi-bin/scan.sh${RESET}        ${WHITE}View your saved remote scan data${RESET}

 ${BOLD_GREEN}\$ curl${RESET} ${BLUE}-s ${HOST}/cgi-bin/agent.sh | bash${RESET}
   └─ ${WHITE}Run the remote scanner agent on your local machine${RESET}

${BOLD_PURPLE}Privacy Note:${RESET} ${WHITE}This is purely educational analytics shenanigans for the heck of it.${RESET}
${WHITE}No info is sent to a remote server.${RESET}

EOF
    
else
    
    # --- BROWSER MODE (HTML) ---#
    export INSTRUCTION_CMD="curl -s http://${HOST_ESCAPED}/cgi-bin/agent.sh | bash"
    
    render_header "Welcome to ASH"
    render_page "welcome.html" '${HOST_ESCAPED} ${INSTRUCTION_CMD}'
    render_footer
    
fi
