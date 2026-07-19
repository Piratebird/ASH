#!/usr/bin/env bash

# ANSI Escape Sequences for terminal colors

# Text Reset
export RESET=$'\e[0m'

# Regular Colors (Catppuccin Mocha)
export BLACK=$'\e[38;2;69;71;90m'      # Surface 1
export RED=$'\e[38;2;243;139;168m'     # Red
export GREEN=$'\e[38;2;166;227;161m'   # Green
export YELLOW=$'\e[38;2;249;226;175m'  # Yellow
export BLUE=$'\e[38;2;137;180;250m'    # Blue
export PURPLE=$'\e[38;2;203;166;247m'  # Mauve
export CYAN=$'\e[38;2;148;226;213m'    # Teal
export WHITE=$'\e[38;2;205;214;244m'   # Text

# Bold Colors
export BOLD_BLACK=$'\e[1;38;2;88;91;112m'     # Surface 2
export BOLD_RED=$'\e[1;38;2;243;139;168m'
export BOLD_GREEN=$'\e[1;38;2;166;227;161m'
export BOLD_YELLOW=$'\e[1;38;2;249;226;175m'
export BOLD_BLUE=$'\e[1;38;2;137;180;250m'
export BOLD_PURPLE=$'\e[1;38;2;203;166;247m'
export BOLD_CYAN=$'\e[1;38;2;148;226;213m'
export BOLD_WHITE=$'\e[1;38;2;205;214;244m'

# Background Colors
export BG_BLACK=$'\e[48;2;30;30;46m'   # Base
export BG_RED=$'\e[48;2;243;139;168m'
export BG_GREEN=$'\e[48;2;166;227;161m'
export BG_YELLOW=$'\e[48;2;249;226;175m'
export BG_BLUE=$'\e[48;2;137;180;250m'
export BG_PURPLE=$'\e[48;2;203;166;247m'
export BG_CYAN=$'\e[48;2;148;226;213m'
export BG_WHITE=$'\e[48;2;205;214;244m'

# Formatting
export BOLD=$'\e[1m'
export UNDERLINE=$'\e[4m'
export INVERT=$'\e[7m'

# Optional: Add utility functions for colorizing text
function colorize() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${RESET}"
}
