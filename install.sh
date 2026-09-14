#!/bin/bash
# i3wm rice install script
# Tested on Linux Mint (Ubuntu/noble-based)
# Reference: https://github.com/Alopes01/Dotfiles/tree/main/FIRST_RICE

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing apt packages..."
sudo apt update
sudo apt install -y \
  i3 i3lock feh polybar rofi picom kitty tmux \
  playerctl light papirus-icon-theme \
  pipx python3-pip imagemagick \
  dex xss-lock network-manager-gnome

echo "==> Installing pywal..."
pipx install pywal
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"

echo "==> Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts
cd /tmp

wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -O JetBrainsMono.zip
unzip -q -o JetBrainsMono.zip -d JetBrainsMono/
cp JetBrainsMono/*.ttf ~/.local/share/fonts/

wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip" -O SymbolsOnly.zip
unzip -q -o SymbolsOnly.zip -d SymbolsOnly/
cp SymbolsOnly/*.ttf ~/.local/share/fonts/

wget -q "https://use.fontawesome.com/releases/v6.5.2/fontawesome-free-6.5.2-desktop.zip" -O fa6.zip
unzip -q -o fa6.zip
cp fontawesome-free-6.5.2-desktop/otfs/*.otf ~/.local/share/fonts/

fc-cache -fv
echo "==> Fonts installed."

cd "$REPO_DIR"

echo "==> Copying configs..."
mkdir -p ~/.config/i3
cp config        ~/.config/i3/config
cp status        ~/.config/i3/status 2>/dev/null || true

mkdir -p ~/.config/polybar
cp polybar/config.ini  ~/.config/polybar/config.ini
cp polybar/launch.sh   ~/.config/polybar/launch.sh
chmod +x ~/.config/polybar/launch.sh

mkdir -p ~/.config/rofi
cp rofi/config.rasi ~/.config/rofi/config.rasi

mkdir -p ~/.config/picom
cp picom.conf ~/.config/picom/picom.conf

mkdir -p ~/.config/kitty
cp kitty.conf ~/.config/kitty/kitty.conf

cp tmux.conf ~/.tmux.conf

echo ""
echo "==> Wallpaper setup"
echo "    Place a wallpaper at: ~/Pictures/wallpaper.jpg"
echo "    Then run: wal -i ~/Pictures/wallpaper.jpg"
echo ""
echo "==> Done! Log out and back into i3 to apply everything."
echo "    Mod key is Super (Windows key). Super+D opens rofi, Super+Return opens kitty."
