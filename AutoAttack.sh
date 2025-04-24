#!/bin/bash

# =================================================
# AutoAttack for Diablo II (Linux Version)
# by whipowill
# =================================================

# INSTALL: sudo apt install evemu-tools
# Script uses evemu-tools to make low-latecy mouse clicks.
# Original version used xdotool but it was too laggy.

# limit windows where this script runs (searches for word)
TARGET_WINDOWS="Diablo|Torchlight|Exile"

# click delay in seconds to limit resource usage
CLICK_DELAY=0.1

# -------------------------------------------------------------------
# DEVICE DETECTION
# -------------------------------------------------------------------

# find keyboard
find_keyboard()
{
    local devices=(
        "AT Translated Set 2 keyboard" 
        $(xinput list --name-only | grep -i "keyboard" | head -1)
    )
    
    for dev in "${devices[@]}"; do
        id=$(xinput list --id-only "$dev" 2>/dev/null)
        [ -n "$id" ] && { echo "$id"; return; }
    done
    echo "ERROR: No keyboard found!" >&2
    exit 1
}

# find mouse
find_mouse()
{
    local mouse=$(ls /dev/input/by-id/* 2>/dev/null | grep -iE "mouse|event" | head -1)
    [ -e "$mouse" ] && { echo "$mouse"; return; }
    
    mouse=$(grep -l "Mouse" /sys/class/input/event*/device/name 2>/dev/null | head -1)
    mouse="/dev/input/${mouse#*/sys/class/input/}"
    [ -e "$mouse" ] && { echo "$mouse"; return; }
    
    mouse=$(ls /dev/input/event* 2>/dev/null | head -1)
    [ -e "$mouse" ] && { echo "$mouse"; return; }
    
    echo "ERROR: No mouse device detected!" >&2
    echo "Available devices:" >&2
    ls /dev/input/ >&2
    exit 1
}

# init devices
KEYBOARD_ID=$(find_keyboard)
MOUSE_DEV=$(find_mouse)

# report
#echo "Using keyboard ID: $KEYBOARD_ID"
#echo "Using mouse device: $MOUSE_DEV"

# -------------------------------------------------------------------
# MAIN SCRIPT
# -------------------------------------------------------------------

# click function using evemu-tools
click()
{
    evemu-event $MOUSE_DEV --type EV_KEY --code BTN_LEFT --value 1 --sync
    evemu-event $MOUSE_DEV --type EV_KEY --code BTN_LEFT --value 0 --sync
}

# initialize window tracking
LAST_WINDOW=""
IN_GAME=0

while true; do
    # get current window (faster than xdotool)
    CURRENT_WINDOW=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | cut -d' ' -f5)
    
    # only check window title when focus changes
    [[ "$CURRENT_WINDOW" != "$LAST_WINDOW" ]] && {
        WIN_NAME=$(xprop -id "$CURRENT_WINDOW" WM_NAME 2>/dev/null | awk -F'"' '{print $2}')
        
        # check windows to see if matches targets
        if [[ "$WIN_NAME" =~ ($TARGET_WINDOWS) ]]; then
            IN_GAME=1
            echo "Target window focused: ${BASH_REMATCH[1]}"
        else
            IN_GAME=0
            echo "Other window focused: ${WIN_NAME:0:20}..."
        fi
        
        LAST_WINDOW="$CURRENT_WINDOW"
    }

    # only check input if in game
    if (( IN_GAME )); then
        xinput --query-state $KEYBOARD_ID | grep -q "key\[65\]=down" && click
    fi
    
    sleep "$CLICK_DELAY"
done
