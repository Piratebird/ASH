#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/../libs/http.sh"

AGENT=$(get_user_agent)

# Collect Data (and sell it for a kebab sandwich)
SYS_HOST=$(hostname)
if [ -f /etc/os-release ]; then
    SYS_OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f 2 || uname -srm)
else
    SYS_OS=$(uname -srm)
fi
SYS_UPTIME=$(uptime -p 2>/dev/null || echo "Unknown")
SYS_LOAD=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}' || echo "N/A")
SYS_CORES=$(nproc 2>/dev/null || echo "1")

# Memory Parsing (Using free -m)
# off topic i fucking hate awk
if command -v free &> /dev/null; then
    MEM_TOT=$(free -m | awk '/^Mem:/{print $2}')
    MEM_USE=$(free -m | awk '/^Mem:/{print $3}')
    [[ "$MEM_TOT" -gt 0 ]] 2>/dev/null && MEM_PCT=$(( MEM_USE * 100 / MEM_TOT )) || MEM_PCT=0
    MEM_STR="${MEM_USE}M / ${MEM_TOT}M"
else
    MEM_PCT=0; MEM_STR="N/A"
fi

# Disk Parsing (Root filesystem)
DISK_TOT=$(df -h / | awk 'NR==2 {print $2}')
DISK_USE=$(df -h / | awk 'NR==2 {print $3}')
DISK_PCT=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_STR="${DISK_USE} / ${DISK_TOT}"

# Multi-line text data
TOP_PROCS=$(ps -eo pid,pcpu,pmem,comm --sort=-pcpu 2>/dev/null | head -n 6)
if command -v docker &> /dev/null; then
    DOCKER_OUT=$(docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null)
    [ -z "$DOCKER_OUT" ] && DOCKER_OUT="No containers running."
else
    DOCKER_OUT="Docker not installed."
fi
PORTS_OUT=$(ss -tlnp 2>/dev/null | awk '{print $4}' | grep -o ':[0-9]*$' | tr '\n' ' ' || echo "N/A")
TIME_NOW=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

if [[ "$AGENT" == curl* ]]; then
    send_200_text
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    print_logo "ASH - STATUS" "\"Server Health & Vitals\"" ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
    echo ""
    echo " ${BOLD_BLUE}Hostname${RESET} : ${WHITE}${SYS_HOST}${RESET}"
    echo " ${BOLD_BLUE}OS${RESET}       : ${WHITE}${SYS_OS}${RESET}"
    echo " ${BOLD_BLUE}Uptime${RESET}   : ${WHITE}${SYS_UPTIME}${RESET}"
    echo " ${BOLD_BLUE}Load${RESET}     : ${WHITE}${SYS_LOAD}${RESET}"
    echo " ${BOLD_BLUE}Cores${RESET}    : ${WHITE}${SYS_CORES}${RESET}"
    echo " ${BOLD_BLUE}Memory${RESET}   : ${WHITE}${MEM_STR} (${MEM_PCT}%)${RESET}"
    echo " ${BOLD_BLUE}Disk${RESET}     : ${WHITE}${DISK_STR} (${DISK_PCT}%)${RESET}"
    echo " ${BOLD_BLUE}Ports${RESET}    : ${WHITE}${PORTS_OUT}${RESET}"
    echo ""
    echo "${BOLD_PURPLE}--- Top Processes ---${RESET}"
    echo "${WHITE}${TOP_PROCS}${RESET}"
    echo ""
    echo "${BOLD_PURPLE}--- Docker Containers ---${RESET}"
    echo "${WHITE}${DOCKER_OUT}${RESET}"
    echo ""
    echo "${BOLD_WHITE}===========================================================${RESET}"
else
    send_200_json
    # Build and output JSON
    cat <<EOF
{
    "hostname": "$(json_escape "$SYS_HOST")",
    "os": "$(json_escape "$SYS_OS")",
    "uptime": "$(json_escape "$SYS_UPTIME")",
    "load": "$(json_escape "$SYS_LOAD")",
    "cpu_cores": "$(json_escape "$SYS_CORES")",
    "memory": {
        "text": "$(json_escape "$MEM_STR")",
        "percent": ${MEM_PCT:-0}
    },
    "disk": {
        "text": "$(json_escape "$DISK_STR")",
        "percent": ${DISK_PCT:-0}
    },
    "top_processes": "$(json_escape "$TOP_PROCS")",
    "docker": "$(json_escape "$DOCKER_OUT")",
    "ports": "$(json_escape "$PORTS_OUT")",
    "timestamp": "$(json_escape "$TIME_NOW")"
}
EOF
fi