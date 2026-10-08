#!/bin/bash
#
# THE PHALANX — uninstaller
# Restores gsettings from the most recent backup and removes theme files.
#
# Usage:  ./uninstall.sh
#         ./uninstall.sh --backup-dir ~/.phalanx-backup-20260101-120000
#

set -e

THEME_NAME="The-Phalanx"
USER_THEMES_DIR="$HOME/.themes"
USER_WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Phalanx"
USER_FONT_DIR="$HOME/.local/share/fonts"

# Find most recent backup
BACKUP_DIR=$(ls -dt "$HOME"/.phalanx-backup-* 2>/dev/null | head -1)

# Parse args
for arg in "$@"; do
    case "$arg" in
        --backup-dir=*) BACKUP_DIR="${arg#*=}" ;;
        --help|-h)
            grep '^#' "${BASH_SOURCE[0]}" | head -10
            exit 0
            ;;
    esac
done

bold() { echo -e "\033[1;37m$*\033[0m"; }
log()  { echo -e "\033[0;37m[\033[1;37mPHALANX\033[0;37m]\033[0m $*"; }

echo ""
bold "  ╔══════════════════════════════════════════════════════════════╗"
bold "  ║                   THE PHALANX · UNINSTALL                    ║"
bold "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    log "No backup found in $HOME/.phalanx-backup-*"
    log "Nothing to restore. Removing theme files only."
    BACKUP_DIR=""
else
    log "Using backup: $BACKUP_DIR"
fi

# Restore gsettings from backup
if [ -n "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/gsettings.txt" ]; then
    log "Restoring gsettings from backup..."

    # Parse the backup file and restore settings
    # We just apply sensible defaults if restore fails
    restore_setting() {
        local schema="$1" key="$2" value="$3"
        if [ -n "$value" ] && [ "$value" != "(unset)" ]; then
            gsettings set "$schema" "$key" "$value" 2>/dev/null || true
        fi
    }

    # Extract values from backup (simple grep)
    GTK_THEME=$(grep -A1 "Interface" "$BACKUP_DIR/gsettings.txt" | grep gtk-theme | awk -F"'" '{print $2}')
    ICON_THEME=$(grep -A2 "Interface" "$BACKUP_DIR/gsettings.txt" | grep icon-theme | awk -F"'" '{print $2}')
    CINNAMON_THEME=$(grep -A1 "Cinnamon theme" "$BACKUP_DIR/gsettings.txt" | grep name | awk -F"'" '{print $2}')
    WM_THEME=$(grep -A1 "Cinnamon WM" "$BACKUP_DIR/gsettings.txt" | grep theme | head -1 | awk -F"'" '{print $2}')
    FONT_NAME=$(grep "font-name" "$BACKUP_DIR/gsettings.txt" | head -1 | awk -F"'" '{print $2}')
    MONO_FONT=$(grep "monospace-font-name" "$BACKUP_DIR/gsettings.txt" | awk -F"'" '{print $2}')
    TITLEBAR_FONT=$(grep "titlebar-font" "$BACKUP_DIR/gsettings.txt" | awk -F"'" '{print $2}')
    PICTURE_URI=$(grep "picture-uri " "$BACKUP_DIR/gsettings.txt" | head -1 | awk -F"'" '{print $2}')

    [ -n "$GTK_THEME" ] && gsettings set org.cinnamon.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
    [ -n "$ICON_THEME" ] && gsettings set org.cinnamon.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null || true
    [ -n "$CINNAMON_THEME" ] && gsettings set org.cinnamon.theme name "$CINNAMON_THEME" 2>/dev/null || true
    [ -n "$WM_THEME" ] && gsettings set org.cinnamon.desktop.wm.preferences theme "$WM_THEME" 2>/dev/null || true
    [ -n "$FONT_NAME" ] && gsettings set org.cinnamon.desktop.font font-name "$FONT_NAME" 2>/dev/null || true
    [ -n "$MONO_FONT" ] && gsettings set org.cinnamon.desktop.font monospace-font-name "$MONO_FONT" 2>/dev/null || true
    [ -n "$TITLEBAR_FONT" ] && gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "$TITLEBAR_FONT" 2>/dev/null || true
    [ -n "$PICTURE_URI" ] && gsettings set org.cinnamon.desktop.background picture-uri "$PICTURE_URI" 2>/dev/null || true

    log "  ✓ gsettings restored"
fi

# Restore previous theme dir if backup has it
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR/The-Phalanx-prev" ]; then
    log "Restoring previous The-Phalanx theme directory..."
    rm -rf "$USER_THEMES_DIR/$THEME_NAME"
    mv "$BACKUP_DIR/The-Phalanx-prev" "$USER_THEMES_DIR/$THEME_NAME"
    log "  ✓ previous theme restored"
else
    log "Removing theme directory..."
    rm -rf "$USER_THEMES_DIR/$THEME_NAME"
fi

# Remove icon theme
log "Removing icon theme..."
rm -rf "$HOME/.icons/The-Phalanx"

# Remove wallpapers
log "Removing wallpapers..."
rm -rf "$USER_WALLPAPER_DIR"

# Remove terminal color sourcing from .bashrc
log "Removing terminal color sourcing from ~/.bashrc..."
if [ -f "$HOME/.bashrc" ]; then
    # Remove the block we added
    sed -i '/# === PHALANX-TERMINAL/,/# === END PHALANX-TERMINAL/d' "$HOME/.bashrc"
fi
rm -f "$HOME/.phalanx-terminal.sh"

# Remove neofetch config (only if it's ours)
if [ -f "$HOME/.config/neofetch/config.conf" ]; then
    if grep -q "The Phalanx" "$HOME/.config/neofetch/config.conf" 2>/dev/null; then
        rm -f "$HOME/.config/neofetch/config.conf"
        log "  ✓ neofetch config removed"
    fi
fi

# Remove wallpaper rotation script
rm -f "$HOME/.local/bin/phalanx-wallpaper"

# Remove MOTD (sudo)
log "Removing MOTD..."
if sudo true 2>/dev/null; then
    sudo rm -f /etc/update-motd.d/00-phalanx
fi

# Restore GRUB
if [ -n "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/grub.default" ]; then
    log "Restoring GRUB config..."
    if sudo true 2>/dev/null; then
        sudo cp "$BACKUP_DIR/grub.default" /etc/default/grub
        sudo update-grub 2>&1 | tail -2 || true
        log "  ✓ GRUB restored"
    fi
fi
log "Removing GRUB theme..."
if sudo true 2>/dev/null; then
    sudo rm -rf /boot/grub/themes/the-phalanx
fi

# Restore Plymouth
log "Removing Plymouth theme..."
if sudo true 2>/dev/null; then
    # Set the alternatives back to default (mint-logo)
    if [ -f /usr/share/plymouth/themes/mint-logo/mint-logo.plymouth ]; then
        sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/mint-logo/mint-logo.plymouth 2>/dev/null || true
    fi
    sudo rm -rf /usr/share/plymouth/themes/the-phalanx
    sudo update-initramfs -u 2>&1 | tail -2 || true
fi

echo ""
bold "  ╔══════════════════════════════════════════════════════════════╗"
bold "  ║                  UNINSTALL COMPLETE                          ║"
bold "  ╚══════════════════════════════════════════════════════════════╝"
echo ""
log "Backup retained at: $BACKUP_DIR"
log "Log out / restart Cinnamon (Alt+F2 → r) to see changes."
echo ""
