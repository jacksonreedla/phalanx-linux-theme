# THE PHALANX — Fonts

## Strategy

**System UI font:** Inter (clean grotesque sans — for menus, buttons, panel)
- Why not Playfair/Cormorant: Display serifs at 11pt UI text = unreadable
- Inter is the de-facto modern grotesque — pairs with the brutalist aesthetic without competing with it

**Display / ceremonial fonts:** (used in wallpapers, MOTD, neofetch, lock screen)
- Playfair Display — high-contrast Didot-style serif (used in slide deck headings)
- Cormorant Garamond — classical serif body (used in slide deck body copy)
- Cinzel — Trajan caps (used for inscriptions, deity names, page marks)

## Install commands

```bash
# Create user font dir
mkdir -p ~/.local/share/fonts

# Download Inter (UI font)
# Method 1: via apt (older version)
sudo apt install fonts-inter

# Method 2: latest from Google Fonts (recommended)
wget -O /tmp/Inter.zip https://fonts.google.com/download?family=Inter
unzip /tmp/Inter.zip -d ~/.local/share/fonts/Inter

# Download display fonts from Google Fonts
wget -O /tmp/PlayfairDisplay.zip https://fonts.google.com/download?family=Playfair+Display
unzip /tmp/PlayfairDisplay.zip -d ~/.local/share/fonts/PlayfairDisplay

wget -O /tmp/CormorantGaramond.zip https://fonts.google.com/download?family=Cormorant+Garamond
unzip /tmp/CormorantGaramond.zip -d ~/.local/share/fonts/CormorantGaramond

wget -O /tmp/Cinzel.zip https://fonts.google.com/download?family=Cinzel
unzip /tmp/Cinzel.zip -d ~/.local/share/fonts/Cinzel

# Refresh font cache
fc-cache -fv

# Verify
fc-list | grep -iE "inter|playfair|cormorant|cinzel"
```

## Apply system UI font

### Option A — Cinnamon settings (GUI)
1. Menu → Preferences → Fonts
2. Set "Default Font" to **Inter Regular 11**
3. Set "Desktop Font" to **Inter Regular 10**
4. Set "Window Title Font" to **Inter Bold 11**
5. Set "Monospace Font" to **DejaVu Sans Mono 11** (or IBM Plex Mono if installed)

### Option B — gsettings (command line)
```bash
gsettings set org.cinnamon.desktop.font font-name 'Inter 11'
gsettings set org.cinnamon.desktop.font monospace-font-name 'DejaVu Sans Mono 11'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Inter Bold 11'
gsettings set org.nemo.desktop font 'Inter 10'
```

## Anti-aliasing

For crisp, brutalist text rendering:
```bash
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
```
