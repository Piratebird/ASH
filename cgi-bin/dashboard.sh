#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../libs/template.sh"

render_header "ASH Dashboard"
render_page "dashboard.html"
render_footer
