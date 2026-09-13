#!/usr/bin/env bash
# ==============================================================================
#  Silent SDDM Theme & Hyprland Switcher - Automated Installer
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="${SCRIPT_DIR}/theme"
FONTS_SRC="${SCRIPT_DIR}/fonts"
HYPR_SRC="${SCRIPT_DIR}/hyprland"

echo -e "\033[1;36m==>\033[0m Installing Silent SDDM Theme & Hyprland Quick Switcher..."

# 1. Install Theme to /usr/share/sddm/themes/silent
echo -e "\033[1;34m[1/6]\033[0m Installing SDDM theme files to /usr/share/sddm/themes/silent..."
sudo mkdir -p /usr/share/sddm/themes/silent
sudo cp -r "${THEME_SRC}"/* /usr/share/sddm/themes/silent/

# 2. Install Typography & Custom Fonts
echo -e "\033[1;34m[2/6]\033[0m Installing typography (Cracked Code & Oriental Chicken)..."
mkdir -p ~/.local/share/fonts
cp -r "${FONTS_SRC}"/* ~/.local/share/fonts/ 2>/dev/null || true
sudo mkdir -p /usr/local/share/fonts
sudo cp -r "${FONTS_SRC}"/* /usr/local/share/fonts/
sudo chmod 644 /usr/local/share/fonts/*
fc-cache -fv >/dev/null 2>&1 || true
sudo fc-cache -f >/dev/null 2>&1 || true

# 3. Install Helper script for instant switching
echo -e "\033[1;34m[3/6]\033[0m Installing preset switcher backend to /usr/local/bin/set-sddm-preset..."
sudo cp "${HYPR_SRC}/scripts/set-sddm-preset" /usr/local/bin/set-sddm-preset
sudo chmod 755 /usr/local/bin/set-sddm-preset

# 4. Install Sudoers rule for passwordless switching
echo -e "\033[1;34m[4/6]\033[0m Configuring passwordless switching rule in /etc/sudoers.d/..."
sudo cp "${HYPR_SRC}/sudoers.d/sddm-theme-preset" /etc/sudoers.d/sddm-theme-preset
sudo chmod 440 /etc/sudoers.d/sddm-theme-preset

# 5. Install Rofi UI and Script to Hyprland configs
echo -e "\033[1;34m[5/6]\033[0m Installing Rofi menu & Hyprland integration..."
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi"
cp "${HYPR_SRC}/scripts/RofiSddmPreset.sh" "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/"
chmod +x "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/RofiSddmPreset.sh"
cp "${HYPR_SRC}/rofi/config-sddm.rasi" "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/"

# 6. Ensure SDDM configuration is active
echo -e "\033[1;34m[6/6]\033[0m Verifying /etc/sddm.conf.d/theme.conf..."
sudo mkdir -p /etc/sddm.conf.d
if [[ ! -f /etc/sddm.conf.d/theme.conf ]] || ! grep -q "Current=silent" /etc/sddm.conf.d/theme.conf; then
    echo -e "[Theme]\nCurrent=silent" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
fi

echo -e "\033[1;32m==>\033[0m Installation complete! Press \033[1mSUPER + ALT + S\033[0m to switch presets."
