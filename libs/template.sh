#!/usr/bin/env bash

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"

render_header() {
    export PAGE_TITLE="$1"
    send_200_html
    envsubst '${PAGE_TITLE}' < "${TEMPLATE_DIR}/header.html"
}

render_footer() {
    cat "${TEMPLATE_DIR}/footer.html"
}

render_page() {
    local template_file="$1"
    local allowed_vars="$2" # Example: '${PAGE_TITLE} ${HOST}'
    
    if [ -f "${TEMPLATE_DIR}/${template_file}" ]; then
        if [ -n "$allowed_vars" ]; then
            # Only substitute the explicitly allowed variables
            # off topic i dont llike process substitution but wtv
            
            envsubst "$allowed_vars" < "${TEMPLATE_DIR}/${template_file}"
        else
            # If no variables are allowed, just cat the file safely
            cat "${TEMPLATE_DIR}/${template_file}"
        fi
    else
        echo "<div class=\"card\">Error: Template '${template_file}' not found.</div>"
    fi
}
