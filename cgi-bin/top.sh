#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"


# -b tells top to run in "Batch mode" (no interactive terminal shenanigans)
# -n 1 tells top to run exactly 1 iteration and then exit
# head -n 25 limits the output to not send gazillions of background processes

TOP_OUTPUT=$(top -b -n 1 | head -n 25 | html_escape)
export TOP_OUTPUT

AGENT=$(get_user_agent)

if [[ "$AGENT" == curl* ]]; then
    
    # --- curl ---#
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - TOP" "\"System Process Scanner\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo -e "${TOP_OUTPUT}"
    
else
    
    # --- BROWSER MODE --- #
    render_header "Live System Top"
    render_page "top.html" '${TOP_OUTPUT}'
    render_footer
    
fi
