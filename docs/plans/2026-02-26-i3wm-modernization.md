# i3wm Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernize i3wm with polybar, rofi, picom, kitty, and pywal on Linux Mint with dual monitors (HDMI-A-0 + DisplayPort-0), based on Alopes01/FIRST_RICE.

**Architecture:** Direct port adapted for QWERTY layout and Super modifier. Pywal generates colors from the wallpaper and propagates them to all components via Xresources and per-app color files (`~/.cache/wal/`). Polybar replaces i3bar+i3status; each component reads pywal output at startup.

**Tech Stack:** i3-wm 4.23, polybar 3.7, rofi, picom 10.2, kitty, pywal (pipx), feh, playerctl, light, JetBrains Mono Nerd Font, Font Awesome 6 Free

---

### Task 1: Install apt packages

**Files:** none

**Step 1: Update and install**

```bash
sudo apt update && sudo apt install -y \
  polybar rofi picom kitty feh playerctl light \
  papirus-icon-theme pipx python3-pip
```

**Step 2: Verify key installs**

```bash
polybar --version && rofi --version && picom --version && kitty --version && feh --version
```

Expected: version strings for each tool, no "command not found"

**Step 3: Commit note**

```bash
cd ~/.config/i3
git commit --allow-empty -m "chore: apt packages installed for i3 modernization"
```

---

### Task 2: Install pywal via pipx

**Files:** none

**Step 1: Install pywal**

```bash
pipx install pywal
pipx ensurepath
```

**Step 2: Source the updated PATH (or open a new terminal)**

```bash
source ~/.zshrc
```

**Step 3: Verify**

```bash
wal --version
```

Expected: `pywal 3.x.x`

If `wal` is not found after sourcing, add `~/.local/bin` to PATH manually:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

### Task 3: Install Nerd Fonts

**Files:** `~/.local/share/fonts/`

**Step 1: Create fonts directory**

```bash
mkdir -p ~/.local/share/fonts
```

**Step 2: Download JetBrains Mono Nerd Font**

```bash
cd /tmp
wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -O JetBrainsMono.zip
unzip -q JetBrainsMono.zip -d JetBrainsMono/
cp JetBrainsMono/*.ttf ~/.local/share/fonts/
```

**Step 3: Download Symbols Nerd Font Mono**

```bash
wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip" -O SymbolsOnly.zip
unzip -q SymbolsOnly.zip -d SymbolsOnly/
cp SymbolsOnly/*.ttf ~/.local/share/fonts/
```

**Step 4: Install Font Awesome 6**

The apt package `fonts-font-awesome` only provides FA5. Download FA6 manually:

```bash
wget "https://use.fontawesome.com/releases/v6.5.2/fontawesome-free-6.5.2-desktop.zip" -O fa6.zip
unzip -q fa6.zip
cp fontawesome-free-6.5.2-desktop/otfs/*.otf ~/.local/share/fonts/
```

**Step 5: Rebuild font cache**

```bash
fc-cache -fv
```

Expected: ends with `fc-cache: succeeded`

**Step 6: Verify fonts are registered**

```bash
fc-list | grep -i "JetBrains"
fc-list | grep -i "Symbols Nerd"
fc-list | grep -i "Awesome 6"
```

Each command must return at least one result. Note the exact family names returned — you'll need them verbatim for polybar's `font-0`, `font-1`, `font-2` lines in Task 8.

---

### Task 4: Set up wallpaper and initialize pywal

**Files:** `~/Pictures/wallpaper.jpg`

**Step 1: Place a wallpaper**

Copy any JPG or PNG to `~/Pictures/wallpaper.jpg`. This path is hardcoded throughout the setup.

```bash
ls ~/Pictures/wallpaper.jpg   # verify it exists
```

If you don't have one yet, download a sample dark wallpaper:

```bash
# Replace this URL with any direct image link you prefer
wget "https://w.wallhaven.cc/full/85/wallhaven-85rgl7.png" -O ~/Pictures/wallpaper.jpg
```

**Step 2: Run pywal for the first time**

```bash
wal -i ~/Pictures/wallpaper.jpg
```

Expected: terminal colors change immediately to palette derived from the wallpaper. No error output.

**Step 3: Verify color cache**

```bash
ls ~/.cache/wal/
```

Expected: you see files including `colors`, `colors.Xresources`, `colors-kitty.conf`, `wal`

**Step 4: Load colors into Xresources**

```bash
xrdb -merge ~/.cache/wal/colors.Xresources
```

No output = success.

---

### Task 5: Configure picom

**Files:**
- Create: `~/.config/picom/picom.conf`

**Step 1: Create directory**

```bash
mkdir -p ~/.config/picom
```

**Step 2: Write picom.conf**

Write the following to `~/.config/picom/picom.conf`:

```
# Backend: glx for modern hardware, xrender if glx causes issues
backend = "glx";
vsync = true;

# Rounded corners on all windows
corner-radius = 10;

# Exclude dock/panel windows from rounding (polybar)
rounded-corners-exclude = [
  "window_type = 'dock'",
  "window_type = 'desktop'",
  "class_g = 'Polybar'"
];

# No opacity changes
active-opacity = 1.0;
inactive-opacity = 1.0;
frame-opacity = 1.0;

# No fading or shadows — clean look
fading = false;
shadow = false;
```

**Step 3: Test picom starts**

```bash
picom --config ~/.config/picom/picom.conf --daemon
sleep 1
pgrep picom && echo "picom OK"
```

Expected: prints a PID and "picom OK"

**Step 4: Kill test instance**

```bash
pkill picom
```

**Step 5: If glx backend crashes**, switch to xrender:

Edit `~/.config/picom/picom.conf` and change `backend = "glx"` to `backend = "xrender"`.

**Step 6: Commit**

```bash
cd ~/.config/i3
git add -- ../picom/picom.conf 2>/dev/null; git add docs/ 2>/dev/null
git commit -m "feat: add picom config with rounded corners"
```

---

### Task 6: Configure kitty

**Files:**
- Create: `~/.config/kitty/kitty.conf`

**Step 1: Create directory**

```bash
mkdir -p ~/.config/kitty
```

**Step 2: Write kitty.conf**

Write the following to `~/.config/kitty/kitty.conf`:

```
# Font — use exact name from: fc-list | grep -i "JetBrains"
# Common names: "JetBrainsMono Nerd Font" or "JetBrainsMono NF"
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        16.0

# Ligatures
enable_ligatures always

# Scrollback
scrollback_lines 2000

# Load pywal colors — regenerated each time you run `wal -i`
include ~/.cache/wal/colors-kitty.conf

# Shell
shell zsh
shell_integration enabled

# Tab bar
tab_bar_style    fade
tab_bar_edge     bottom

# URL detection
url_style curly
detect_urls yes
```

**Step 3: Verify kitty.conf is valid**

```bash
kitty --config ~/.config/kitty/kitty.conf --detach -- bash -c "sleep 2"
sleep 1
pgrep kitty && echo "kitty OK"
pkill kitty
```

Expected: "kitty OK". If kitty shows a font error, run `fc-list | grep -i "JetBrains"` and use the exact family name shown.

**Step 4: Commit**

```bash
cd ~/.config/i3
git add -- ../kitty/kitty.conf 2>/dev/null
git commit -m "feat: add kitty config with pywal colors and JetBrains Mono Nerd Font"
```

---

### Task 7: Write polybar launch script

**Files:**
- Create: `~/.config/polybar/launch.sh`

**Step 1: Create directory**

```bash
mkdir -p ~/.config/polybar
```

**Step 2: Write launch.sh**

Write the following to `~/.config/polybar/launch.sh`:

```bash
#!/bin/bash

# Kill any running polybar instances
killall -q polybar

# Wait until all instances have exited
while pgrep -x polybar >/dev/null; do sleep 0.5; done

# Launch one bar per connected monitor
# The MONITOR env var tells polybar which screen to use
for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$monitor polybar --reload main 2>&1 | tee -a /tmp/polybar-"$monitor".log &
    disown
done

echo "Bars launched on: $(xrandr --query | grep ' connected' | cut -d' ' -f1 | tr '\n' ' ')"
```

**Step 3: Make executable**

```bash
chmod +x ~/.config/polybar/launch.sh
```

**Step 4: Commit**

```bash
cd ~/.config/i3
git add -- ../polybar/launch.sh 2>/dev/null
git commit -m "feat: add polybar multi-monitor launch script"
```

---

### Task 8: Write polybar config

**Files:**
- Create: `~/.config/polybar/config.ini`

**Step 1: Check exact font names**

Before writing the config, get the exact names polybar needs:

```bash
fc-list | grep -i "JetBrains" | grep -i "Nerd"
fc-list | grep -i "Symbols Nerd"
fc-list | grep -i "Awesome 6" | grep -i "Free"
```

Write down the family names (the part before the colon in each line). You'll substitute them into the `font-0`, `font-1`, `font-2` lines below if they differ from the defaults shown.

**Step 2: Write config.ini**

Write the following to `~/.config/polybar/config.ini`:

```ini
; ~/.config/polybar/config.ini
; Colors sourced from pywal via Xresources (fallbacks if xrdb not loaded)

[colors]
background = ${xrdb:i3wm.color0:#1C1C23}
foreground = ${xrdb:i3wm.color7:#FFFFFF}
primary    = ${xrdb:i3wm.color2:#008000}
alert      = ${xrdb:i3wm.color1:#FF0000}
disabled   = #555555

[bar/main]
; MONITOR is set by launch.sh — one bar per screen
monitor = ${env:MONITOR:}

width    = 98.8%
height   = 24pt
offset-x = 0.8%
offset-y = 1.3%
radius   = 10

background = ${colors.background}
foreground = ${colors.foreground}
line-size  = 2pt

padding-left  = 1
padding-right = 1
module-margin = 1

separator           = " | "
separator-foreground = ${colors.disabled}

; Adjust font names if fc-list shows different family names
font-0 = JetBrainsMono Nerd Font:style=Medium Italic:size=10;2
font-1 = Font Awesome 6 Free:style=Solid:size=10;2
font-2 = Symbols Nerd Font Mono:size=10;2

modules-left   = date
modules-center = i3
modules-right  = pulseaudio memory cpu network powermenu

cursor-click  = pointer
cursor-scroll = ns-resize
enable-ipc    = true
tray-position = none

[module/i3]
type = internal/i3

; Show only workspaces assigned to this bar's monitor
pin-workspaces = true

label-focused            = %index%
label-focused-background = ${colors.primary}
label-focused-padding    = 2

label-unfocused         = %index%
label-unfocused-padding = 2

label-visible            = %index%
label-visible-background = ${colors.primary}
label-visible-padding    = 2

label-urgent            = %index%
label-urgent-background = ${colors.alert}
label-urgent-padding    = 2

[module/date]
type     = internal/date
interval = 5

date     = %H:%M
date-alt = %Y-%m-%d %H:%M:%S

label            = %date%
label-foreground = ${colors.foreground}

[module/pulseaudio]
type = internal/pulseaudio

; Replace VOL with a nerd font glyph if desired (e.g. Font Awesome volume-high)
format-volume-prefix            = "VOL "
format-volume-prefix-foreground = ${colors.primary}
format-volume                   = <label-volume>

label-volume = %percentage%%%

label-muted            = MUTE
label-muted-foreground = ${colors.disabled}

[module/memory]
type     = internal/memory
interval = 2

; Replace MEM with a nerd font glyph if desired
format-prefix            = "MEM "
format-prefix-foreground = ${colors.primary}

label = %percentage_used:2%%

[module/cpu]
type     = internal/cpu
interval = 2

; Replace CPU with a nerd font glyph if desired
format-prefix            = "CPU "
format-prefix-foreground = ${colors.primary}

label = %percentage:2%%

[module/network]
type           = internal/network
interface-type = wireless
interval       = 5

; Show WiFi icon only — no SSID name
; Replace WIFI with a nerd font glyph (Font Awesome: wifi icon U+F1EB)
format-connected   = <label-connected>
label-connected            = "WIFI"
label-connected-foreground = ${colors.primary}

format-disconnected        = <label-disconnected>
label-disconnected            = "NO WIFI"
label-disconnected-foreground = ${colors.disabled}

[module/powermenu]
type = custom/menu

expand-right   = true
format-spacing = 1

label-open            = "PWR"
label-open-foreground = ${colors.alert}

label-close            = "cancel"
label-close-foreground = ${colors.alert}

label-separator            = "|"
label-separator-foreground = ${colors.disabled}

menu-0-0      = reboot
menu-0-0-exec = menu-open-1
menu-0-1      = power off
menu-0-1-exec = menu-open-2

menu-1-0      = cancel
menu-1-0-exec = menu-open-0
menu-1-1      = reboot
menu-1-1-exec = systemctl reboot

menu-2-0      = power off
menu-2-0-exec = systemctl poweroff
menu-2-1      = cancel
menu-2-1-exec = menu-open-0
```

**Step 3: Merge pywal Xresources**

```bash
xrdb -merge ~/.cache/wal/colors.Xresources
```

**Step 4: Test polybar**

```bash
~/.config/polybar/launch.sh
```

Expected: bars appear on both monitors. Check for errors:

```bash
cat /tmp/polybar-HDMI-A-0.log
cat /tmp/polybar-DisplayPort-0.log
```

**Common issue — wrong font name:** If you see `Could not load font`, compare the font name in `font-0/1/2` against the exact output of `fc-list`. Edit the font lines to match exactly.

**Common issue — no pywal colors:** If bar is black/white instead of wallpaper-derived, the xrdb merge didn't take. Run `xrdb -merge ~/.cache/wal/colors.Xresources` then `~/.config/polybar/launch.sh` again.

**Step 5: Kill test polybar**

```bash
killall polybar
```

**Step 6: (Optional) Replace text labels with nerd font icons**

Once the bar is confirmed working, replace the text labels in the module prefixes with actual glyph characters. Open a nerd font cheat sheet at https://www.nerdfonts.com/cheat-sheet to find glyphs, then paste the character directly into the config. Example for volume: replace `"VOL "` with the actual Font Awesome volume character.

**Step 7: Commit**

```bash
cd ~/.config/i3
git add -- ../polybar/config.ini ../polybar/launch.sh 2>/dev/null
git commit -m "feat: add polybar config with dual monitor support and pywal colors"
```

---

### Task 9: Write rofi config

**Files:**
- Create: `~/.config/rofi/config.rasi`

**Step 1: Create directory**

```bash
mkdir -p ~/.config/rofi
```

**Step 2: Write config.rasi**

Write the following to `~/.config/rofi/config.rasi`:

```css
/* ~/.config/rofi/config.rasi */

configuration {
  modi:              "drun,run,window";
  show-icons:        true;
  icon-theme:        "Papirus";
  font:              "JetBrainsMono Nerd Font 10";
  drun-display-format: "{name}";
  display-drun:      " Apps";
  display-run:       " Run";
  display-window:    " Windows";
}

* {
  bg:       #1C1C23;
  fg:       #FFFFFF;
  hl:       #84A4C4;
  sel:      #9FA4C4;
  disabled: #555555;
}

window {
  width:            700px;
  background-color: @bg;
  border:           2px solid;
  border-color:     @hl;
  border-radius:    20px;
  location:         center;
}

mainbox {
  background-color: transparent;
  children:         [ inputbar, listview ];
  spacing:          10px;
  padding:          15px;
}

inputbar {
  background-color: transparent;
  children:         [ prompt, entry ];
  spacing:          5px;
}

prompt {
  background-color: transparent;
  text-color:       @hl;
}

entry {
  background-color: transparent;
  text-color:       @fg;
  placeholder:      "Search...";
  placeholder-color: @disabled;
}

listview {
  background-color: transparent;
  columns:          1;
  lines:            8;
  spacing:          5px;
}

element {
  background-color: transparent;
  text-color:       @fg;
  padding:          5px 10px;
  border-radius:    10px;
}

element selected {
  background-color: @hl;
  text-color:       @bg;
}

element-icon {
  size: 32px;
}
```

**Step 3: Test rofi**

```bash
rofi -show drun
```

Expected: rofi launcher appears with dark theme, rounded borders, app list with Papirus icons. Press Escape to close.

If the font name causes an error, check the exact name:

```bash
fc-list | grep -i "JetBrains"
```

and update the `font:` line in config.rasi to match.

**Step 4: Commit**

```bash
cd ~/.config/i3
git add -- ../rofi/config.rasi 2>/dev/null
git commit -m "feat: add rofi config with dark theme and nerd font"
```

---

### Task 10: Back up existing i3 config

**Files:**
- Create: `~/.config/i3/config.bak`

**Step 1: Copy current config**

```bash
cp ~/.config/i3/config ~/.config/i3/config.bak
```

**Step 2: Commit backup**

```bash
cd ~/.config/i3
git add config.bak
git commit -m "chore: backup original i3 config before modernization"
```

---

### Task 11: Write new i3 config

**Files:**
- Modify: `~/.config/i3/config`

**Step 1: Replace config with modernized version**

Completely replace `~/.config/i3/config` with the following:

```
# i3 config file (v4)
# Modernized rice — Mod: Super | Layout: QWERTY | Monitors: HDMI-A-0 + DisplayPort-0

set $mod Mod4

# Font
font pango:JetBrains Mono Bold 9

# Gaps (requires i3 4.22+; you have 4.23)
gaps inner 10
gaps outer 4

# Borders: 5px on all windows, titles centered
default_border pixel 5
title_align center

# Colors sourced from pywal via Xresources
# Fallback values used if xrdb not loaded yet
set_from_resource $fg i3wm.color7 #FFFFFF
set_from_resource $bg i3wm.color0 #1C1C23
set_from_resource $ac i3wm.color2 #008000

# class                 border  backgr. text  indicator child_border
client.focused          $ac     $ac     $fg   $ac       $ac
client.focused_inactive $bg     $bg     $fg   $bg       $bg
client.unfocused        $bg     $bg     $fg   $bg       $bg
client.urgent           #FF0000 #FF0000 $fg   #FF0000   #FF0000
client.placeholder      $bg     $bg     $fg   $bg       $bg

# ── Autostart: run once on login ──────────────────────────────────────────────
exec --no-startup-id dex --autostart --environment i3
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
exec --no-startup-id nm-applet

# ── Autostart: run on every reload/restart ────────────────────────────────────
# Restore last pywal color scheme and merge into Xresources
exec_always --no-startup-id wal -R
# Set wallpaper
exec_always --no-startup-id feh --bg-fill ~/Pictures/wallpaper.jpg
# Compositor with rounded corners
exec_always --no-startup-id picom --config ~/.config/picom/picom.conf
# Status bars (one per monitor)
exec_always --no-startup-id ~/.config/polybar/launch.sh

# ── Volume ────────────────────────────────────────────────────────────────────
set $refresh_bar killall -SIGUSR1 polybar
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_bar
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_bar
bindsym XF86AudioMute        exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_bar
bindsym XF86AudioMicMute     exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_bar

# ── Media keys ────────────────────────────────────────────────────────────────
bindsym XF86AudioPlay exec --no-startup-id playerctl play-pause
bindsym XF86AudioNext exec --no-startup-id playerctl next
bindsym XF86AudioPrev exec --no-startup-id playerctl previous

# ── Brightness ────────────────────────────────────────────────────────────────
bindsym XF86MonBrightnessUp   exec --no-startup-id light -A 5
bindsym XF86MonBrightnessDown exec --no-startup-id light -U 5

# ── Drag & drop ───────────────────────────────────────────────────────────────
floating_modifier $mod
tiling_drag modifier titlebar

# ── App launchers ─────────────────────────────────────────────────────────────
bindsym $mod+Return exec kitty
bindsym $mod+Shift+q kill
bindsym $mod+d exec --no-startup-id rofi -modi drun,run,window -show drun

# ── Session ───────────────────────────────────────────────────────────────────
bindsym $mod+c exec i3lock
bindsym $mod+p exec --no-startup-id ~/.config/polybar/launch.sh

# ── Focus (QWERTY: j=left k=down l=up ;=right) ───────────────────────────────
bindsym $mod+j          focus left
bindsym $mod+k          focus down
bindsym $mod+l          focus up
bindsym $mod+semicolon  focus right
bindsym $mod+Left       focus left
bindsym $mod+Down       focus down
bindsym $mod+Up         focus up
bindsym $mod+Right      focus right

# ── Move ──────────────────────────────────────────────────────────────────────
bindsym $mod+Shift+j         move left
bindsym $mod+Shift+k         move down
bindsym $mod+Shift+l         move up
bindsym $mod+Shift+semicolon move right
bindsym $mod+Shift+Left      move left
bindsym $mod+Shift+Down      move down
bindsym $mod+Shift+Up        move up
bindsym $mod+Shift+Right     move right

# ── Layout ────────────────────────────────────────────────────────────────────
bindsym $mod+h split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+Shift+space floating toggle
bindsym $mod+space       focus mode_toggle
bindsym $mod+a           focus parent

# ── Workspaces ────────────────────────────────────────────────────────────────
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

# Monitor assignments (preserved from original config)
workspace 1 output HDMI-A-0
workspace 2 output HDMI-A-0
workspace 3 output HDMI-A-0
workspace 4 output DisplayPort-0
workspace 5 output DisplayPort-0
workspace 6 output DisplayPort-0

# Switch workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# Move container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# ── i3 control ────────────────────────────────────────────────────────────────
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

# ── Resize mode ───────────────────────────────────────────────────────────────
mode "resize" {
    bindsym j         resize shrink width  10 px or 10 ppt
    bindsym k         resize grow   height 10 px or 10 ppt
    bindsym l         resize shrink height 10 px or 10 ppt
    bindsym semicolon resize grow   width  10 px or 10 ppt

    bindsym Left  resize shrink width  10 px or 10 ppt
    bindsym Down  resize grow   height 10 px or 10 ppt
    bindsym Up    resize shrink height 10 px or 10 ppt
    bindsym Right resize grow   width  10 px or 10 ppt

    bindsym Return mode "default"
    bindsym Escape mode "default"
    bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"
```

**Step 2: Verify config syntax before reloading**

```bash
i3 -C -c ~/.config/i3/config
```

Expected: `No errors.` — do NOT reload if there are errors.

---

### Task 12: Reload i3 and verify

**Step 1: Merge pywal Xresources (one more time to be safe)**

```bash
xrdb -merge ~/.cache/wal/colors.Xresources
```

**Step 2: Reload i3**

Press `Alt+Shift+C` (old binding, still works during transition), or run:

```bash
i3-msg reload
```

Expected:
- Polybar appears on both monitors (i3bar disappears)
- Windows get rounded corners (picom)
- Wallpaper is set by feh
- Mod key is now Super

**Step 3: Test each keybinding**

| Keybinding | Expected |
|---|---|
| `Super+Return` | Kitty terminal opens |
| `Super+D` | Rofi launcher appears |
| `Super+C` | Screen locks (i3lock) |
| `Super+P` | Polybar reloads |
| `Super+Shift+C` | i3 reloads |
| `Super+1` through `Super+6` | Switch workspaces |
| Volume keys | Volume changes, polybar updates |

**Step 4: Test pywal color change**

Run pywal with your wallpaper to verify full propagation:

```bash
wal -i ~/Pictures/wallpaper.jpg
```

Then press `Super+Shift+R` to restart i3. Colors should match the wallpaper palette across: terminal, polybar, window borders.

**Step 5: Commit**

```bash
cd ~/.config/i3
git add config
git commit -m "feat: modernize i3 config — Super mod, gaps, pywal colors, polybar, rofi, picom, kitty"
```

---

### Troubleshooting Reference

**Polybar not appearing:**
```bash
~/.config/polybar/launch.sh
cat /tmp/polybar-HDMI-A-0.log
```
Check for font errors. Verify monitor names: `xrandr --query | grep " connected"`

**Font name mismatch in polybar:**
```bash
fc-list | grep -i "JetBrains"
# Use exact family name from output in font-0 line
```

**Picom crashing (glx backend):**
Edit `~/.config/picom/picom.conf`: change `backend = "glx"` to `backend = "xrender"`

**Pywal colors not showing in polybar after reload:**
```bash
xrdb -merge ~/.cache/wal/colors.Xresources
~/.config/polybar/launch.sh
```

**wal command not found after pipx install:**
```bash
export PATH="$HOME/.local/bin:$PATH"
# Add this line to ~/.zshrc to persist
```

**Kitty not finding pywal colors:**
```bash
ls ~/.cache/wal/colors-kitty.conf   # must exist
wal -R                              # regenerate if missing
```

**Rofi font error:**
```bash
fc-list | grep -i "JetBrains"
# Update font: line in config.rasi to exact family name
```
