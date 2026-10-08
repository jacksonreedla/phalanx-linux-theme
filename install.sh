#!/bin/bash
#
# THE PHALANX — Linux Mint Cinnamon theme installer
# Version: 1.0.0
#
# Usage:  ./install.sh
#         ./install.sh --skip-grub      # skip GRUB theme (no sudo prompt for it)
#         ./install.sh --skip-plymouth  # skip Plymouth boot splash
#         ./install.sh --skip-fonts     # skip font download (offline machines)
#         ./install.sh --dry-run        # show what would be done, do nothing
#
# This script:
#   1. Backs up your existing theme settings to ~/.phalanx-backup-TIMESTAMP/
#   2. Copies GTK3, GTK4, Cinnamon theme files to ~/.themes/The-Phalanx/
#   3. Copies wallpapers to ~/Pictures/Wallpapers/Phalanx/
#   4. Installs Inter + Playfair Display + Cormorant + Cinzel fonts
#   5. Applies the theme via gsettings
#   6. (optional) Installs GRUB theme to /boot/grub/themes/the-phalanx/
#   7. (optional) Installs Plymouth boot splash to /usr/share/plymouth/themes/the-phalanx/
#   8. Sets up terminal colors + neofetch + MOTD
#   9. Sets a random deity wallpaper
#
# All operations are logged. To revert: ./uninstall.sh
#

set -e

# === Config ===
THEME_NAME="The-Phalanx"
THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_THEMES_DIR="$HOME/.themes"
USER_WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Phalanx"
USER_FONT_DIR="$HOME/.local/share/fonts"
BACKUP_DIR="$HOME/.phalanx-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$BACKUP_DIR/install.log"

# Flags
SKIP_GRUB=false
SKIP_PLYMOUTH=false
SKIP_FONTS=false
DRY_RUN=false

# === Parse args ===
for arg in "$@"; do
    case "$arg" in
        --skip-grub) SKIP_GRUB=true ;;
        --skip-plymouth) SKIP_PLYMOUTH=true ;;
        --skip-fonts) SKIP_FONTS=true ;;
        --dry-run) DRY_RUN=true ;;
        --help|-h)
            grep '^#' "${BASH_SOURCE[0]}" | head -30
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

# === Helpers ===
log()  { echo -e "\033[0;37m[\033[1;37mPHALANX\033[0;37m]\033[0m $*" | tee -a "$LOG_FILE"; }
err()  { echo -e "\033[0;90m[\033[1;37mPHALANX ERROR\033[0;90m]\033[0m $*" >&2; }
bold() { echo -e "\033[1;37m$*\033[0m"; }

run() {
    if $DRY_RUN; then
        echo "  [dry-run] $*"
    else
        eval "$@"
    fi
}

# === Header ===
echo ""
bold "  ╔══════════════════════════════════════════════════════════════╗"
bold "  ║                  THE PHALANX · INSTALLER                     ║"
bold "  ║              Monochrome brutalist Linux Mint                 ║"
bold "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

# Dry-run notice
if $DRY_RUN; then
    echo "  \033[0;90m[DRY RUN — no changes will be made]\033[0m"
    echo ""
fi

# === Sanity checks ===
if [ ! -d "$THEME_DIR/gtk-3.0" ] || [ ! -d "$THEME_DIR/cinnamon" ]; then
    err "Theme directory not found at: $THEME_DIR"
    err "Run this script from inside the extracted theme folder."
    exit 1
fi

# Check we're on Mint Cinnamon
DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
if [ "$DE" != "x-cinnamon" ] && [ "$DE" != "cinnamon" ]; then
    log "Warning: XDG_CURRENT_DESKTOP is '$XDG_CURRENT_DESKTOP', not 'X-Cinnamon'."
    log "Theme will still install, but gsettings may not apply correctly."
fi

# === Backup ===
# Create backup dir + log file BEFORE the first log() call — log() tees to
# $LOG_FILE, which lives inside $BACKUP_DIR, so the dir must exist first or
# tee fails under `set -e`.
run "mkdir -p '$BACKUP_DIR'"
run "touch '$LOG_FILE'"
log "Backing up current settings to: $BACKUP_DIR"

# Backup gsettings
if ! $DRY_RUN; then
    {
        echo "=== Phalanx backup $(date) ==="
        echo ""
        echo "--- Cinnamon desktop font (org.cinnamon.desktop.interface font-name) ---"
        gsettings get org.cinnamon.desktop.interface font-name 2>/dev/null || echo "(unset)"
        echo ""
        echo "--- Cinnamon WM ---"
        gsettings get org.cinnamon.desktop.wm.preferences theme 2>/dev/null || echo "(unset)"
        gsettings get org.cinnamon.desktop.wm.preferences titlebar-font 2>/dev/null || echo "(unset)"
        echo ""
        echo "--- Cinnamon theme ---"
        gsettings get org.cinnamon.theme name 2>/dev/null || echo "(unset)"
        echo ""
        echo "--- Interface ---"
        gsettings get org.cinnamon.desktop.interface gtk-theme 2>/dev/null || echo "(unset)"
        gsettings get org.cinnamon.desktop.interface icon-theme 2>/dev/null || echo "(unset)"
        gsettings get org.cinnamon.desktop.interface cursor-theme 2>/dev/null || echo "(unset)"
        echo ""
        echo "--- Background ---"
        gsettings get org.cinnamon.desktop.background picture-uri 2>/dev/null || echo "(unset)"
        gsettings get org.cinnamon.desktop.background picture-uri-dark 2>/dev/null || echo "(unset)"
        echo ""
        echo "--- Existing themes ---"
        ls -la "$USER_THEMES_DIR/" 2>/dev/null || echo "(no user themes dir)"
    } > "$BACKUP_DIR/gsettings.txt" 2>&1
fi
log "  ✓ gsettings backed up"

# Backup existing theme dir if it exists
if [ -d "$USER_THEMES_DIR/$THEME_NAME" ]; then
    run "mv '$USER_THEMES_DIR/$THEME_NAME' '$BACKUP_DIR/The-Phalanx-prev'"
    log "  ✓ previous theme version backed up"
fi

# === Install theme files ===
log "Installing theme files to: $USER_THEMES_DIR/$THEME_NAME"
run "mkdir -p '$USER_THEMES_DIR/$THEME_NAME'"

# GTK3
run "cp -r '$THEME_DIR/gtk-3.0' '$USER_THEMES_DIR/$THEME_NAME/'"
log "  ✓ GTK3 theme"

# GTK4
run "cp -r '$THEME_DIR/gtk-4.0' '$USER_THEMES_DIR/$THEME_NAME/'"
log "  ✓ GTK4 theme"

# Cinnamon
run "cp -r '$THEME_DIR/cinnamon' '$USER_THEMES_DIR/$THEME_NAME/'"
log "  ✓ Cinnamon theme (with metacity window borders)"

# Index file (declares the theme)
run "cat > '$USER_THEMES_DIR/$THEME_NAME/index.theme' <<'INDEX'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=The-Phalanx
Comment=Monochrome brutalist editorial × Greek/Roman statuary
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=The-Phalanx
MetacityTheme=The-Phalanx
IconTheme=The-Phalanx
CursorTheme=Adwaita
ButtonLayout=:minimize,maximize,close
INDEX"
log "  ✓ index.theme"

# === Install icon theme ===
log "Installing icon theme (The-Phalanx, inherits Papirus-Dark)"
run "mkdir -p '$HOME/.icons'"
if [ -d "$HOME/.icons/The-Phalanx" ]; then
    run "rm -rf '$HOME/.icons/The-Phalanx'"
fi
run "cp -r '$THEME_DIR/icons' '$HOME/.icons/The-Phalanx'"
log "  ✓ icon theme installed"

# Check if Papirus-Dark is available; if not, install it
if ! $DRY_RUN; then
    if ! fc-list 2>/dev/null | grep -qi papirus; then
        if ! ls /usr/share/icons/Papirus-Dark 2>/dev/null >/dev/null; then
            log "  Papirus-Dark not found. Installing via apt..."
            if command -v apt >/dev/null 2>&1; then
                sudo apt install -y papirus-icon-theme 2>&1 | tail -3 | tee -a "$LOG_FILE" || {
                    log "  ! Could not install papirus-icon-theme. Install manually: sudo apt install papirus-icon-theme"
                }
            fi
        fi
    fi
fi

# === Install wallpapers ===
log "Installing wallpapers to: $USER_WALLPAPER_DIR"
run "mkdir -p '$USER_WALLPAPER_DIR'"
run "cp '$THEME_DIR/wallpapers/'*.jpg '$USER_WALLPAPER_DIR/'"
log "  ✓ 8 deity wallpapers installed"

# === Install fonts ===
if ! $SKIP_FONTS; then
    log "Installing fonts (Inter, Playfair Display, Cormorant Garamond, Cinzel)"
    run "mkdir -p '$USER_FONT_DIR'"

    if ! $DRY_RUN; then
        # Try apt first (fastest, no internet dependency issues)
        if ! fc-list 2>/dev/null | grep -qi "inter"; then
            log "  Installing Inter via apt..."
            sudo apt install -y fonts-inter 2>&1 | tail -3 | tee -a "$LOG_FILE" || log "  ! fonts-inter not in apt — will try Google Fonts"
        fi

        # Download display fonts from Google Fonts (if not already present).
        # NOTE: the old code fetched https://fonts.google.com/download?family=...,
        # which serves an HTML frontend page, not a zip — so unzip always failed.
        # The reliable path is the CSS2 API (fonts.googleapis.com/css2), which
        # returns real .ttf URLs on fonts.gstatic.com.
        install_font() {
            local name="$1"        # human name, e.g. "Playfair Display"
            local query="$2"       # CSS2 query, e.g. "Playfair+Display:wght@400;700"
            local dest_dir="$USER_FONT_DIR/${name// /}"
            if fc-list 2>/dev/null | grep -qi "$name"; then
                log "  $name already present, skipping"
                return
            fi
            log "  Downloading $name via Google Fonts CSS2 API..."
            local css
            css=$(curl -sS -A "Mozilla/5.0" "https://fonts.googleapis.com/css2?family=${query}&display=swap" 2>>"$LOG_FILE")
            if [ -z "$css" ]; then
                log "  ! Could not fetch CSS2 for $name (network?)"
                return
            fi
            mkdir -p "$dest_dir"
            local count=0
            # Extract each .ttf URL on its own line and pull them all.
            while IFS= read -r ttf_url; do
                [ -z "$ttf_url" ] && continue
                local fname
                fname=$(basename "$ttf_url")
                if curl -sSL -A "Mozilla/5.0" "$ttf_url" -o "$dest_dir/$fname" 2>>"$LOG_FILE"; then
                    count=$((count + 1))
                fi
            done <<< "$(printf '%s\n' "$css" | sed -nE 's|.*url\((https://[^)]+\.ttf)\).*|\1|p')"
            if [ "$count" -gt 0 ]; then
                log "  ✓ $name: $count variant(s) installed"
            else
                log "  ! $name: no .ttf URLs found in CSS response"
            fi
        }

        install_font "Playfair Display" "Playfair+Display:wght@400;700;900"
        install_font "Cormorant Garamond" "Cormorant:wght@400;500;600;700"
        install_font "Cinzel" "Cinzel:wght@400;700;900"

        # Refresh font cache
        fc-cache -fv >/dev/null 2>&1
        log "  ✓ fonts installed and cached"
    fi
else
    log "Skipping fonts (--skip-fonts)"
fi

# === Apply gsettings ===
log "Applying theme via gsettings..."

apply_setting() {
    if ! $DRY_RUN; then
        gsettings set "$1" "$2" "$3" 2>>"$LOG_FILE" || true
    fi
}

# GTK theme
apply_setting org.cinnamon.desktop.interface gtk-theme "$THEME_NAME"
# Icon theme
apply_setting org.cinnamon.desktop.interface icon-theme "$THEME_NAME"
# Cinnamon theme
apply_setting org.cinnamon.theme name "$THEME_NAME"
# Window manager theme
apply_setting org.cinnamon.desktop.wm.preferences theme "$THEME_NAME"

# Fonts (if Inter is installed)
if ! $DRY_RUN; then
    if fc-list 2>/dev/null | grep -qi "inter"; then
        # NOTE: org.cinnamon.desktop.font does not exist in Cinnamon 6.x.
        # The UI font key lives under org.cinnamon.desktop.interface (font-name).
        # monospace-font-name is not a key on this schema; only font-name is set here.
        apply_setting org.cinnamon.desktop.interface font-name "Inter 11"
        apply_setting org.cinnamon.desktop.wm.preferences titlebar-font "Inter Bold 11"
        apply_setting org.nemo.desktop font "Inter 10"
    fi
fi

# Anti-aliasing for crisp brutalist text
apply_setting org.gnome.desktop.interface font-antialiasing "grayscale"
apply_setting org.gnome.desktop.interface font-hinting "slight"
apply_setting org.gnome.desktop.interface text-scaling-factor 1.0

log "  ✓ gsettings applied"

# === Set wallpaper ===
log "Setting random deity wallpaper..."
if ! $DRY_RUN; then
    WALLPAPER=$(ls "$USER_WALLPAPER_DIR/"phalanx-*.jpg 2>/dev/null | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        WALLPAPER_URI="file://$WALLPAPER"
        gsettings set org.cinnamon.desktop.background picture-uri "$WALLPAPER_URI" 2>>"$LOG_FILE" || true
        gsettings set org.cinnamon.desktop.background picture-uri-dark "$WALLPAPER_URI" 2>>"$LOG_FILE" || true
        gsettings set org.cinnamon.desktop.background picture-options "zoom" 2>>"$LOG_FILE" || true
        log "  ✓ wallpaper set: $(basename "$WALLPAPER")"
    fi
fi

# === Terminal colors ===
log "Setting up terminal colors..."
if ! $DRY_RUN; then
    # Backup existing .bashrc append marker
    if ! grep -q "PHALANX-TERMINAL" "$HOME/.bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# === PHALANX-TERMINAL — added by install.sh ==="
            echo "[ -f \"\$HOME/.phalanx-terminal.sh\" ] && source \"\$HOME/.phalanx-terminal.sh\""
            echo "# === END PHALANX-TERMINAL ==="
            echo ""
        } >> "$HOME/.bashrc"
        cp "$THEME_DIR/terminal/phalanx-terminal.sh" "$HOME/.phalanx-terminal.sh"
        chmod +x "$HOME/.phalanx-terminal.sh"
        log "  ✓ terminal colors added to ~/.bashrc"
    fi

    # Neofetch
    if command -v neofetch >/dev/null 2>&1; then
        mkdir -p "$HOME/.config/neofetch"
        cp "$THEME_DIR/terminal/neofetch.conf" "$HOME/.config/neofetch/config.conf"
        log "  ✓ neofetch config installed"
    else
        log "  ! neofetch not installed. Install with: sudo apt install neofetch"
        log "    Then re-run install.sh, or copy $THEME_DIR/terminal/neofetch.conf to ~/.config/neofetch/config.conf"
    fi
fi

# === MOTD ===
if ! $DRY_RUN; then
    log "Installing MOTD (requires sudo)..."
    if sudo true 2>/dev/null; then
        sudo mkdir -p /etc/update-motd.d
        sudo cp "$THEME_DIR/terminal/motd.sh" /etc/update-motd.d/00-phalanx
        sudo chmod +x /etc/update-motd.d/00-phalanx
        log "  ✓ MOTD installed — will print on next login"
    else
        log "  ! Skipped MOTD (sudo not available)"
    fi
fi

# === GRUB theme ===
if ! $SKIP_GRUB; then
    log "Installing GRUB theme (requires sudo)..."
    if ! $DRY_RUN && sudo true 2>/dev/null; then
        sudo mkdir -p /boot/grub/themes/the-phalanx
        sudo cp "$THEME_DIR/grub/"* /boot/grub/themes/the-phalanx/

        # Backup existing GRUB_THEME setting
        if sudo test -f /etc/default/grub; then
            sudo cp /etc/default/grub "$BACKUP_DIR/grub.default"
        fi

        # Add or replace GRUB_THEME line
        if sudo grep -q "^GRUB_THEME=" /etc/default/grub; then
            sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/the-phalanx/theme.txt"|' /etc/default/grub
        else
            echo 'GRUB_THEME="/boot/grub/themes/the-phalanx/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
        fi

        # Disable submenu so all kernels show at top level
        if sudo grep -q "^GRUB_DISABLE_SUBMENU=" /etc/default/grub; then
            sudo sed -i 's|^GRUB_DISABLE_SUBMENU=.*|GRUB_DISABLE_SUBMENU=y|' /etc/default/grub
        else
            echo 'GRUB_DISABLE_SUBMENU=y' | sudo tee -a /etc/default/grub >/dev/null
        fi

        # Update GRUB
        if command -v update-grub >/dev/null 2>&1; then
            sudo update-grub 2>&1 | tail -3 | tee -a "$LOG_FILE"
            log "  ✓ GRUB theme installed and grub updated"
        else
            log "  ✓ GRUB theme installed. Run 'sudo update-grub' to apply."
        fi
    else
        log "  ! Skipped GRUB (sudo not available, or dry-run)"
    fi
else
    log "Skipping GRUB theme (--skip-grub)"
fi

# === Plymouth boot splash ===
if ! $SKIP_PLYMOUTH; then
    log "Installing Plymouth boot splash (requires sudo)..."
    if ! $DRY_RUN && sudo true 2>/dev/null; then
        sudo mkdir -p /usr/share/plymouth/themes/the-phalanx
        sudo cp "$THEME_DIR/plymouth/"* /usr/share/plymouth/themes/the-phalanx/

        # Register the theme
        sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/the-phalanx/the-phalanx.plymouth 100 2>&1 | tee -a "$LOG_FILE"
        sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/the-phalanx/the-phalanx.plymouth 2>&1 | tee -a "$LOG_FILE"

        # Update initramfs
        sudo update-initramfs -u 2>&1 | tail -3 | tee -a "$LOG_FILE"

        log "  ✓ Plymouth boot splash installed"
    else
        log "  ! Skipped Plymouth (sudo not available, or dry-run)"
    fi
else
    log "Skipping Plymouth (--skip-plymouth)"
fi

# === Done ===
echo ""
bold "  ╔══════════════════════════════════════════════════════════════╗"
bold "  ║                    INSTALLATION COMPLETE                    ║"
bold "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

log "Backup: $BACKUP_DIR"
log "Log:    $BACKUP_DIR/install.log"
echo ""

if ! $DRY_RUN; then
    echo -e "  \033[0;90m— The form outlives the name.\033[0m"
    echo ""
    echo "  Next steps:"
    echo "    1. Log out and back in (or restart Cinnamon: Alt+F2 → r → Enter)"
    echo "    2. Open a new terminal — Phalanx colors + neofetch will load"
    echo "    3. Reboot to see the GRUB menu + Plymouth boot splash"
    echo ""
    echo "  To revert:  ./uninstall.sh"
    echo "  To rotate wallpaper:  ~/.local/bin/phalanx-wallpaper (created on next step)"
    echo ""

    # Create wallpaper rotation script
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/phalanx-wallpaper" <<'EOF'
#!/bin/bash
# Rotate to a random Phalanx deity wallpaper
WP_DIR="$HOME/Pictures/Wallpapers/Phalanx"
if [ -d "$WP_DIR" ]; then
    NEW=$(ls "$WP_DIR"/phalanx-*.jpg 2>/dev/null | shuf -n 1)
    if [ -n "$NEW" ]; then
        gsettings set org.cinnamon.desktop.background picture-uri "file://$NEW"
        gsettings set org.cinnamon.desktop.background picture-uri-dark "file://$NEW"
        echo "Set wallpaper: $(basename "$NEW")"
    fi
fi
EOF
    chmod +x "$HOME/.local/bin/phalanx-wallpaper"
fi
