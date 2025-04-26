#!/bin/bash

# =================================================
# AutoAttack for Diablo II (Linux Version)
# by whipowill
# =================================================

# INSTALL: sudo apt install evemu-tools evtest
# Script uses evemu-tools to make low-latecy mouse clicks.
# Original version used xdotool but it was too laggy.
# Script also uses xinput and evtest to determine mouse & keyboard.

# limit windows where this script runs (searches for word)
TARGET_WINDOWS="Diablo|Torchlight|Exile"

# click delay (seconds) to limit resource usage
CLICK_DELAY=0.1

# spacebar must be held this long (seconds) before clicking starts
SPACEBAR_HOLD_DURATION=0.1 # this lets you still use spacebar in chat

# register your devices
KEYBOARD_ID=16 # find using "xinput list"
MOUSE_DEV=/dev/input/event5 # find using "sudo evtest"

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
SPACEBAR_PRESSED_TIME=0
SPACEBAR_THRESHOLD=0
SPACEBAR_ACTIVE=0

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
        # check if spacebar is currently pressed
        if xinput --query-state $KEYBOARD_ID | grep -q "key\[65\]=down"; then
            # if spacebar wasn't pressed before, record the start time
            if (( !SPACEBAR_ACTIVE )); then
                SPACEBAR_PRESSED_TIME=$(date +%s.%3N)
                SPACEBAR_ACTIVE=1
            else
                # determine if spacebar has been held long enough
                if (( !SPACEBAR_THRESHOLD )); then
                    CURRENT_TIME=$(date +%s.%3N)
                    ELAPSED=$(echo "$CURRENT_TIME - $SPACEBAR_PRESSED_TIME" | bc)
                    if (( $(echo "$ELAPSED >= $SPACEBAR_HOLD_DURATION" | bc -l) )); then
                        SPACEBAR_THRESHOLD=1
                    fi
                fi

                # if conditions met, click
                if (( SPACEBAR_THRESHOLD )); then
                    click
                fi
            fi
        else
            # spacebar is not pressed, reset state
            SPACEBAR_ACTIVE=0
            SPACEBAR_THRESHOLD=0
            SPACEBAR_PRESSED_TIME=0
        fi
    fi

    sleep "$CLICK_DELAY"
done