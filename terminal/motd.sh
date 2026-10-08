#!/bin/bash
#
# THE PHALANX — MOTD (Message of the Day)
# Place at: /etc/update-motd.d/00-phalanx
# Make executable: sudo chmod +x /etc/update-motd.d/00-phalanx
# Will print on every SSH / TTY login.

# Deities rotate daily — one deity presides per day
DEITIES=("APOLLO · KITHAROIDOS" "JUPITER · OPTIMUS MAXIMUS" "ATHENA · STRATEGOS" "SATURN · KRONOS" "MERCURY · HERMES" "MINERVA · CUSTOS" "HERCULES · INVICTUS" "MARS · MILES")
MAXIMS=("Stone remembers what flesh forgets." "The shield belongs to the man on your left." "What moves as one cannot be turned aside." "What is formed in silence remains in silence." "The line extends forward." "The order chooses; the chosen do not choose back." "The body that holds its shape survives the charge." "We do not lead. We march.")

# Day-of-year modulo pantheon length
DAY=$(date +%j)
IDX=$(( DAY % 8 ))
DEITY="${DEITIES[$IDX]}"
MAXIM="${MAXIMS[$IDX]}"

# Get system info
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
USER=$(whoami)
DATE=$(date +"%A, %B %d · %H:%M")

# Print MOTD
cat <<EOF

$(printf '\033[1;37m')╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   $(printf '\033[1;37m')THE PHALANX$(printf '\033[0;90m')   ·   $(printf '\033[0;37m')VOL. I$(printf '\033[0;90m')   ·   $(printf '\033[0;37m')MMXXVI$(printf '\033[0;90m')                              ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║   $(printf '\033[1;37m')${DEITY}$(printf '\033[0;90m')                                       ║
║   $(printf '\033[0;37m')${MAXIM}$(printf '\033[0;90m')                                          ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║   $(printf '\033[0;90m')HOST    $(printf '\033[0;37m')${HOSTNAME}$(printf '\033[0m')                                            ║
║   $(printf '\033[0;90m')KERNEL  $(printf '\033[0;37m')${KERNEL}$(printf '\033[0m')                                       ║
║   $(printf '\033[0;90m')UPTIME  $(printf '\033[0;37m')${UPTIME}$(printf '\033[0m')                                            ║
║   $(printf '\033[0;90m')LOAD    $(printf '\033[0;37m')${LOAD}$(printf '\033[0m')                                            ║
║   $(printf '\033[0;90m')USER    $(printf '\033[0;37m')${USER}$(printf '\033[0m')                                              ║
║   $(printf '\033[0;90m')DATE    $(printf '\033[0;37m')${DATE}$(printf '\033[0m')                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
$(printf '\033[0m')
EOF

# Reset colors
printf '\033[0m'
