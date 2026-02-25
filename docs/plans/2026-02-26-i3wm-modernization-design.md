# i3wm Modernization Design

**Date:** 2026-02-26
**Reference:** https://github.com/Alopes01/Dotfiles/tree/main/FIRST_RICE
**Approach:** Direct port with adaptations for Linux Mint, QWERTY layout, and dual monitors

---

## Goal

Replace the current minimal i3wm setup with a modern rice based on the FIRST_RICE reference. The result should be visually polished, dynamically themed via pywal, and fully functional on Linux Mint with a dual-monitor setup (HDMI-A-0 + DisplayPort-0).

---

## Components

### New Installs

| Tool | Purpose | Source |
|------|---------|--------|
| Polybar | Status bar (replaces i3bar + i3status) | apt |
| Rofi | App launcher (replaces i3-dmenu-desktop) | apt |
| Picom | Compositor (rounded corners, compositing) | apt |
| Kitty | Terminal emulator | apt |
| Pywal | Dynamic color generation from wallpaper | pip |
| feh | Wallpaper setter | apt |
| playerctl | Media key control | apt |
| light | Brightness key control | apt |
| papirus-icon-theme | Icons for Rofi | apt |
| JetBrains Mono Nerd Font | Primary font | manual/nerd-fonts |
| Font Awesome 6 | Bar icons | apt/manual |
| Symbols Nerd Font Mono | Extra symbols | manual/nerd-fonts |

### Kept As-Is

- i3-wm, i3lock, nm-applet, xss-lock, PulseAudio
- `~/.custom-scripts/setup_displays.sh`
- Existing workspace assignments (1–3 on HDMI-A-0, 4–6 on DisplayPort-0)

---

## i3 Config Changes

**Modifier:** `Mod1` (Alt) → `Mod4` (Super/Windows key)

**Keybindings:**
- Navigation: `j/k/l/ç` (AZERTY) → `j/k/l/;` (QWERTY)
- Terminal: `$mod+Return` → Kitty
- Launcher: `$mod+d` → Rofi
- Lock: `$mod+c` → i3lock
- Reload Polybar: `$mod+p`
- Media: playerctl play/pause/next/prev
- Brightness: light +5/-5

**Appearance:**
- Inner gaps: 10px, outer gaps: 4px, top gap: 46px (Polybar clearance)
- Border width: 5px, window titles centered
- Colors: sourced from `~/.Xresources` (pywal output)

**Autostart (exec_always):**
1. `wal -R` — restore pywal colors
2. `feh --bg-fill ~/Pictures/wallpaper.*` — set wallpaper
3. `picom --config ~/.config/picom/picom.conf`
4. `~/.config/polybar/launch.sh`
5. nm-applet, xss-lock (existing)

---

## Polybar

**Config location:** `~/.config/polybar/config.ini`
**Launch script:** `~/.config/polybar/launch.sh`

**Bar appearance:**
- Height: 24px, width: 98.8%
- Rounded corners: 10px radius
- Position: top, slightly inset (0.8% x-offset, 1.3% y-offset)
- Font: JetBrains Mono NL Nerd Font + Font Awesome 6 + Symbols Nerd Font Mono
- Colors: xrdb/pywal variables

**Modules:**
- Left: date/time
- Center: i3 workspaces (nerd font icons, workspace-specific per monitor)
- Right: volume, memory, CPU, WiFi (icon only, no SSID name), power menu

**Dual monitor:** One bar per monitor. Launch script detects HDMI-A-0 and DisplayPort-0 via xrandr and spawns a bar on each.

---

## Rofi

**Config location:** `~/.config/rofi/config.rasi`

- Dark palette: bg `#1C1C23`, highlight `#84A4C4`, text `#FFFFFF`
- Font: JetBrains Mono Nerd Font 10
- Width: 700px, centered, 20px border radius
- Background image: `~/Pictures/wallpaper.*`
- Modes: drun, run, window switcher
- Icons: Papirus (32px)

---

## Kitty

**Config location:** `~/.config/kitty/kitty.conf`

- Font: JetBrains Mono Nerd Font 16pt
- Colors: loaded from `~/.cache/wal/colors-kitty.conf` (pywal)
- Shell: zsh
- Shell integration: `wal -R` on startup
- Ligatures enabled, 2000 line scrollback

---

## Picom

**Config location:** `~/.config/picom/picom.conf`

- Rounded corners: 10px radius
- Minimal config (no heavy blur/shadows)

---

## Pywal

**Workflow:**
- Set wallpaper + generate colors: `wal -i ~/Pictures/wallpaper.jpg`
- Colors propagate to: Kitty, Polybar (via xrdb), i3 borders, Rofi
- Login restore: `wal -R` (in i3 autostart)
- Wallpaper location: `~/Pictures/` (user adds their own)
