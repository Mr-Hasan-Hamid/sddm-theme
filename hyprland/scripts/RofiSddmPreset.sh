#!/usr/bin/env bash
# ==============================================================================
#  SDDM Theme Preset Selector for Hyprland
#  Switches between Silent presets (Silvia, Rei, Ken, Catppuccin, etc.)
# ==============================================================================

SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
ROFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-sddm.rasi"
META="/usr/share/sddm/themes/silent/metadata.desktop"

# Refresh wallpaper link for Rofi background theme
if [[ -x "$SCRIPTSDIR/RofiFocusedWallpaperLink.sh" ]]; then
    "$SCRIPTSDIR/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true
fi

# Determine currently active preset
CURRENT_PRESET="silvia"
if [[ -f "$META" ]]; then
    CURRENT_LINE=$(grep "^ConfigFile=" "$META" || true)
    if [[ -n "$CURRENT_LINE" ]]; then
        CURRENT_PRESET=$(basename "$CURRENT_LINE" .conf | sed 's/configs\///')
    fi
fi

# Presets mapping (display -> preset_id)
declare -A PRESET_MAP=(
    ["󰄛  Silvia"]="silvia"
    ["🌸  Rei"]="rei"
    ["⚔️  Ken"]="ken"
    ["☕  Catppuccin Mocha"]="catppuccin-mocha"
    ["☕  Catppuccin Macchiato"]="catppuccin-macchiato"
    ["☕  Catppuccin Frappé"]="catppuccin-frappe"
    ["☕  Catppuccin Latte"]="catppuccin-latte"
    ["🖥️  Default (Center)"]="default"
    ["◀️  Default (Left)"]="default-left"
    ["▶️  Default (Right)"]="default-right"
)

# Ordered menu list
MENU_ITEMS=(
    "󰄛  Silvia"
    "🌸  Rei"
    "⚔️  Ken"
    "☕  Catppuccin Mocha"
    "☕  Catppuccin Macchiato"
    "☕  Catppuccin Frappé"
    "☕  Catppuccin Latte"
    "🖥️  Default (Center)"
    "◀️  Default (Left)"
    "▶️  Default (Right)"
    "───────────────────────────"
    "👁️  Test Current in Preview Window"
)

# Build display options with active marker
DISPLAY_OPTIONS=()
DEFAULT_ROW=0
idx=0

for item in "${MENU_ITEMS[@]}"; do
    preset_id="${PRESET_MAP[$item]}"
    if [[ -n "$preset_id" && "$preset_id" == "$CURRENT_PRESET" ]]; then
        DISPLAY_OPTIONS+=("$item  ✓")
        DEFAULT_ROW=$idx
    else
        DISPLAY_OPTIONS+=("$item")
    fi
    ((idx++))
done

# Check if rofi is already running
if pgrep -x rofi >/dev/null; then
    killall rofi 2>/dev/null || true
fi

# Launch Rofi
CHOICE=$(printf '%s\n' "${DISPLAY_OPTIONS[@]}" | rofi -i -dmenu \
    -p "SDDM Theme" \
    -mesg "Active: $CURRENT_PRESET | Select preset to switch" \
    -selected-row "$DEFAULT_ROW" \
    -config "$ROFI_CONFIG")

if [[ -z "$CHOICE" ]]; then
    exit 0
fi

# Strip the active checkmark if present
CLEAN_CHOICE=$(echo "$CHOICE" | sed 's/  ✓//')

if [[ "$CLEAN_CHOICE" == "───────────────────────────" ]]; then
    exit 0
fi

if [[ "$CLEAN_CHOICE" == "👁️  Test Current in Preview Window" ]]; then
    notify-send -u low "SDDM" "Launching preview window (Press Esc to close)"
    sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/silent &
    exit 0
fi

SELECTED_PRESET="${PRESET_MAP[$CLEAN_CHOICE]}"

if [[ -n "$SELECTED_PRESET" ]]; then
    sudo /usr/local/bin/set-sddm-preset "$SELECTED_PRESET"
    notify-send -u normal -i "preferences-desktop-theme" "SDDM Theme" "Switched to: $SELECTED_PRESET\n(Cracked Code & Oriental Chicken applied)"
fi
