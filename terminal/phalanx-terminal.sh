#!/bin/bash
#
# THE PHALANX — terminal color scheme
# Apply with:  source phalanx-terminal.sh
# Or paste into ~/.bashrc / ~/.zshrc to make permanent.
#
# Pure monochrome — black bg, white fg, mid-grays for syntax.
# No colors, no warm tones. Brutalist.

# === ANSI 16-color palette ===
# Format: ESC ]4;N;rgb:RR/GG/BB BEL
# Black / Red / Green / Yellow / Blue / Magenta / Cyan / White
# (Normal + Bright)

phalanx_apply_colors() {
    local R="\033]4;"
    local B="\007"
    # 0 — black (bg)
    printf "${R}0;rgb:00/00/00${B}"
    # 1 — red — replaced with mid gray (errors stay visible but not red)
    printf "${R}1;rgb:8A/8A/8A${B}"
    # 2 — green — replaced with dim white (success states)
    printf "${R}2;rgb:D4/D4/D4${B}"
    # 3 — yellow — replaced with bright white (warnings)
    printf "${R}3;rgb:FF/FF/FF${B}"
    # 4 — blue — replaced with light gray
    printf "${R}4;rgb:D4/D4/D4${B}"
    # 5 — magenta — replaced with muted gray
    printf "${R}5;rgb:8A/8A/8A${B}"
    # 6 — cyan — replaced with bright gray
    printf "${R}6;rgb:E8/E8/E8${B}"
    # 7 — white (fg) — pure white
    printf "${R}7;rgb:FF/FF/FF${B}"
    # 8 — bright black — dark gray
    printf "${R}8;rgb:4A/4A/4A${B}"
    # 9 — bright red — bright gray
    printf "${R}9;rgb:D4/D4/D4${B}"
    # 10 — bright green — pure white
    printf "${R}10;rgb:FF/FF/FF${B}"
    # 11 — bright yellow — pure white
    printf "${R}11;rgb:FF/FF/FF${B}"
    # 12 — bright blue — pure white
    printf "${R}12;rgb:FF/FF/FF${B}"
    # 13 — bright magenta — light gray
    printf "${R}13;rgb:D4/D4/D4${B}"
    # 14 — bright cyan — pure white
    printf "${R}14;rgb:FF/FF/FF${B}"
    # 15 — bright white — pure white
    printf "${R}15;rgb:FF/FF/FF${B}"

    # Foreground / background / cursor
    printf "\033]10;rgb:FF/FF/FF\007"   # fg
    printf "\033]11;rgb:00/00/00\007"   # bg
    printf "\033]12;rgb:FF/FF/FF\007"   # cursor
    printf "\033]13;rgb:FF/FF/FF\007"   # mouse fg
    printf "\033]14;rgb:00/00/00\007"   # mouse bg

    # Selection
    printf "\033]17;rgb:FF/FF/FF\007"            # selection bg
    printf "\033]19;rgb:00/00/00\007"            # selected text
    printf "\033]4;231;rgb:00/00/00${B}"         # override xterm 231 -> black
    printf "\033]4;232;rgb:00/00/00${B}"         # override xterm 232 -> black
}

# === PS1 prompt — minimal monochrome ===
phalanx_ps1() {
    # Format: "[\D{%H:%M}] \u@\h:\w\n$ "
    # Monochrome — no colors, just structure
    PS1='\[\e[1m\]\D{%H:%M}\[\e[0m\] \[\e[0;37m\]\u\[\e[0m\]@\[\e[0;37m\]\h\[\e[0m\]:\[\e[1;37m\]\w\[\e[0m\]\n$ '
}

# === Apply ===
phalanx_apply_colors
phalanx_ps1

# Aliases for monochrome ls (force --color=none to override Mint defaults)
alias ls='ls --color=never'
alias grep='grep --color=never'
alias diff='diff --color=never'

# Welcome message — prints once per shell session
phalanx_welcome() {
    if [ -z "$_PHALANX_WELCOMED" ]; then
        export _PHALANX_WELCOMED=1
        echo ""
        echo -e "\e[1;37m   THE PHALANX\e[0m   \e[0;37m·\e[0m   \e[0;37mVOL. I\e[0m   \e[0;37m·\e[0m   \e[0;37mMMXXVI\e[0m"
        echo -e "\e[0;90m   — The form outlives the name.\e[0m"
        echo ""
    fi
}
phalanx_welcome

unset -f phalanx_apply_colors phalanx_ps1 phalanx_welcome
