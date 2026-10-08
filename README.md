# THE PHALANX — Linux Mint Cinnamon Theme

> **Monochrome brutalist editorial × Greek/Roman statuary**
> Pure black / white / gray. No color, no ornament. Type does all the work.

A complete desktop theme for Linux Mint Cinnamon, built to match the design system of the same name. Every surface — wallpaper, GTK windows, Cinnamon panel, window borders, GRUB menu, boot splash, terminal, login banner — speaks the same monochrome language, with a pagan deity presiding over each wallpaper in the rotating set.

---

## What's in the box

| Component | Description |
|---|---|
| **8 wallpapers** | 1920×1080 monochrome deity portraits — Apollo, Jupiter, Athena, Saturn, Mercury, Minerva, Hercules, Mars — each with brutalist typography overlay (deity name, epithet, maxim, Roman numeral, Phalanx chapter mark) |
| **GTK3 theme** | `gtk-3.0/gtk.css` — sharp corners, hairline borders, pure monochrome. No gradients. |
| **GTK4 theme** | `gtk-4.0/gtk.css` — same aesthetic for libadwaita apps |
| **Cinnamon theme** | `cinnamon/cinnamon.css` — panel, menu, applets, popup menus, calendar, desklets, OSD, dialogs |
| **Metacity window borders** | `cinnamon/metacity-1/metacity-theme-3.xml` — 1px borders, no rounded corners, minimal X/square/line window buttons |
| **Icon theme** | `icons/index.theme` — inherits from **Papirus-Dark** (install papirus-icon-theme separately) |
| **GRUB theme** | `grub/` — Mars wallpaper background, monochrome menu items, Phalanx chapter mark |
| **Plymouth boot splash** | `plymouth/` — pure black screen, "THE PHALANX" centered, thin white progress line grows across the screen |
| **Terminal colors** | `terminal/phalanx-terminal.sh` — pure monochrome ANSI palette, minimal PS1 prompt, monochrome `ls`/`grep`/`diff` aliases |
| **neofetch config** | `terminal/neofetch.conf` — custom Phalanx ASCII logo, monochrome info colors |
| **MOTD** | `terminal/motd.sh` — rotates daily through the 8 deities, prints hostname/kernel/uptime/load with deity maxim of the day |
| **install.sh** | Automated installer — backs up existing config, copies files, applies gsettings, sets wallpaper |
| **uninstall.sh** | Reverts everything from the most recent backup |

---

## Quick start

```bash
# 1. Extract the tarball
tar xzf the-phalanx-linux-theme.tar.gz
cd the-phalanx-linux-theme

# 2. Run the installer
./install.sh

# 3. Follow the on-screen prompts
#    (will ask for sudo for GRUB + Plymouth + MOTD)

# 4. Log out and back in, or restart Cinnamon: Alt+F2 → r → Enter

# 5. Reboot to see GRUB + Plymouth
```

---

## Install options

```bash
./install.sh                          # full install (default)
./install.sh --skip-grub              # skip GRUB theme (no sudo needed for it)
./install.sh --skip-plymouth          # skip Plymouth boot splash
./install.sh --skip-grub --skip-plymouth  # user-space only, no sudo at all
./install.sh --skip-fonts             # skip font downloads (offline machines)
./install.sh --dry-run                # show what would be done, change nothing
```

---

## Requirements

| Component | Required? | Install |
|---|---|---|
| Linux Mint 21+ (Cinnamon) | Required | — |
| `papirus-icon-theme` | Required for icons | `sudo apt install papirus-icon-theme` (installer will try) |
| `fonts-inter` | Recommended for UI | `sudo apt install fonts-inter` (installer will try) |
| `neofetch` | Optional, for terminal banner | `sudo apt install neofetch` |
| Internet access | Needed for font downloads | Skip with `--skip-fonts` if offline |

The installer will check for these and install what it can via `apt`.

---

## What gets modified

### User-space (no sudo)
- `~/.themes/The-Phalanx/` — theme files (created)
- `~/.icons/The-Phalanx/` — icon theme (created)
- `~/Pictures/Wallpapers/Phalanx/` — 8 wallpapers (created)
- `~/.local/share/fonts/` — Inter, Playfair Display, Cormorant Garamond, Cinzel (added)
- `~/.bashrc` — adds Phalanx terminal color sourcing (3 lines, marked)
- `~/.phalanx-terminal.sh` — terminal color script (created)
- `~/.config/neofetch/config.conf` — Phalanx neofetch config (created, replaces existing)
- `~/.local/bin/phalanx-wallpaper` — wallpaper rotation script (created)
- `gsettings` — applies theme name, icon theme, fonts, wallpaper, anti-aliasing

### System (sudo)
- `/boot/grub/themes/the-phalanx/` — GRUB theme (created)
- `/etc/default/grub` — adds `GRUB_THEME` line (backed up first)
- `/usr/share/plymouth/themes/the-phalanx/` — Plymouth theme (created)
- Plymouth alternatives — sets Phalanx as default (reversible)
- `/etc/update-motd.d/00-phalanx` — MOTD script (created)
- `initramfs` — rebuilt for Plymouth

### Backups
Every install creates a timestamped backup at `~/.phalanx-backup-YYYYMMDD-HHMMSS/` containing:
- `gsettings.txt` — all your previous gsettings values
- `grub.default` — your previous `/etc/default/grub`
- `The-Phalanx-prev/` — your previous Phalanx theme version (if any)
- `install.log` — full install log

To revert: `./uninstall.sh` (uses the most recent backup automatically).

---

## Rotating wallpapers

The installer creates `~/.local/bin/phalanx-wallpaper` — run it anytime to switch to a random deity:

```bash
phalanx-wallpaper
```

Or set up a cron job to rotate daily:

```bash
# crontab -e
@daily /home/your-user/.local/bin/phalanx-wallpaper
```

---

## Customizing

### Change the system font
Open **Menu → Preferences → Fonts** and change any of the four font slots. The brutalist aesthetic pairs well with:
- **Inter** (default, what the installer sets)
- **IBM Plex Sans**
- **Helvetica Now** (if you have it)
- **DejaVu Sans** (Mint default — fine fallback)

### Tweak the GTK theme
Edit `~/.themes/The-Phalanx/gtk-3.0/gtk.css` — the color tokens are at the top:
```css
@define-color phalanx_bg           #000000;
@define-color phalanx_bg_elevated  #141414;
@define-color phalanx_fg           #FFFFFF;
@define-color phalanx_fg_dim       #D4D4D4;
@define-color phalanx_fg_muted     #8A8A8A;
@define-color phalanx_rule         rgba(255,255,255,0.32);
@define-color phalanx_rule_strong  rgba(255,255,255,0.85);
```
Want pure white background instead of black? Swap `phalanx_bg` to `#FFFFFF` and `phalanx_fg` to `#000000` (inverted brutalist).

### Tweak the Cinnamon panel
Edit `~/.themes/The-Phalanx/cinnamon/cinnamon.css` — search for `#panel` to change panel height, padding, or border.

### Tweak the GRUB background
Replace `~/.themes/.../grub/background.png` (or `/boot/grub/themes/the-phalanx/background.png` after install) with any 1920×1080 PNG. Run `sudo update-grub`.

---

## Troubleshooting

### Theme doesn't apply
- Log out and back in (or `Alt+F2` → `r` → Enter to restart Cinnamon)
- Check **Menu → Preferences → Themes** — "The-Phalanx" should be selected for Window, GTK, Icons, Desktop
- Run `gsettings get org.cinnamon.theme name` — should print `'The-Phalanx'`

### Icons look wrong / missing
- Install papirus-icon-theme: `sudo apt install papirus-icon-theme`
- The Phalanx icon theme inherits from Papirus-Dark, so without Papirus installed you'll get fallback GNOME icons

### GRUB theme doesn't show
- Run `sudo update-grub`
- Check `/etc/default/grub` has `GRUB_THEME="/boot/grub/themes/the-phalanx/theme.txt"`
- Check `/boot/grub/themes/the-phalanx/background.png` exists

### Plymouth doesn't show on boot
- Run `sudo update-initramfs -u`
- Check `sudo update-alternatives --display default.plymouth` — Phalanx should be the active alternative
- Plymouth only shows during boot if your kernel uses `splash` in `GRUB_CMDLINE_LINUX_DEFAULT` (Mint enables this by default)

### Terminal colors don't apply
- Open a new terminal window
- Check `~/.bashrc` contains the Phalanx block (search for "PHALANX-TERMINAL")
- Run `source ~/.phalanx-terminal.sh` to test immediately

### Fonts look wrong
- Run `fc-cache -fv` to rebuild the font cache
- Check `fc-list | grep -iE "inter|playfair|cormorant|cinzel"`
- The system UI uses Inter (sans). The serif fonts (Playfair, Cormorant, Cinzel) are for wallpapers, MOTD, and neofetch only — they don't replace the UI font.

---

## Deity roster

| # | Deity | Epithet | Domain | Maxim |
|---|---|---|---|---|
| I | Apollo | Kitharoidos | Beauty · Arts · The Form | Stone remembers what flesh forgets. |
| II | Jupiter | Optimus Maximus | Authority · The Threshold | The shield belongs to the man on your left. |
| III | Athena | Strategos | Strategy · The Doctrine | What moves as one cannot be turned aside. |
| IV | Saturn | Kronos | Time · The Record | What is formed in silence remains in silence. |
| V | Mercury | Hermes | Motion · The Forward Column | The line extends forward. |
| VI | Minerva | Custos | Guardian · The Threshold | The order chooses; the chosen do not choose back. |
| VII | Hercules | Invictus | The Hero · The Formed | The body that holds its shape survives the charge. |
| VIII | Mars | MILES | War · The March | We do not lead. We march. |

---

## Design system reference

This theme is the OS-level instantiation of the broader Phalanx design system. The slide deck and full style guide PDF are also available. The design system covers:

- **Foundations** — color palette (pure monochrome), typography scale (Playfair Display / Cormorant Garamond / Cinzel), spacing (8px base), grid (12-column with 32px gutters)
- **Components** — buttons (sharp corners, hairline borders), entries, lists, menus, dialogs, all in pure black/white
- **Patterns** — editorial splits, three-column broadsheets, full-bleed statuary, centered manifesto
- **Principles** — type does all the work; whitespace does the rest; no ornament; no color

---

## Uninstall

```bash
cd the-phalanx-linux-theme
./uninstall.sh
```

Restores everything from the most recent `~/.phalanx-backup-*` directory. The backup is preserved after uninstall in case you want to re-install later.

---

## License

The theme code (CSS, shell scripts, configs) is yours to modify and redistribute.

The deity photographs are sourced from public-domain museum collections and stock photography. The wallpapers are derivative works produced by the Phalanx wallpaper generator.

---

## Credits

**Design system:** The Phalanx
**Type:** Playfair Display (Claus Eggers Sørensen), Cormorant Garamond (Christian Thalmann), Cinzel (Natanael Gama), Inter (Rasmus Andersson)
**Statuary:** Public-domain Greek/Roman classical sculpture photography
**Built for:** Linux Mint 21+ Cinnamon

---

*— The form outlives the name.*
