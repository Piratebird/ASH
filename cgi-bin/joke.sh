#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"

AGENT=$(get_user_agent)

JOKE=$(timeout 5s curl -s \
    -H "Accept: text/plain" \
    -H "User-Agent: ASH Bash API (https://github.com/piratebird/ASH)" \
    "https://icanhazdadjoke.com/" 2>/dev/null)

if [ -z "$JOKE" ]; then
    JOKE="Why do programmers prefer dark mode? Because light attracts bugs."
fi

if [[ "$AGENT" == curl* ]]; then
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - JOKES" "\"Humor as a Service\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo ""
    echo "  ${BOLD_PURPLE}Dad Joke of the Day:${RESET}"
    echo "  ${WHITE}${JOKE}${RESET}"
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
else
    send_200_json
    cat <<EOF
{"joke": "$(json_escape "$JOKE")"}
EOF
fi
