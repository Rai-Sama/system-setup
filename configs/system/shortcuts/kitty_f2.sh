#!/bin/bash

# 1. Identify the current workspace
CURRENT_WS=$(wmctrl -d | awk '$2 == "*" {print $1}')

# 2. Find the Kitty window ID strictly on the current workspace
WIN=$(wmctrl -lx | \
      awk -v ws="$CURRENT_WS" '$2 == ws && $3 == "kitty.kitty" {print $1; exit}')

# 3. Minimize all current windows to reveal the desktop wallpaper
wmctrl -k on

# 4. Give Cinnamon's window manager a tiny fraction of a second to process the animation
sleep 0.15

# 5. Bring Kitty back up
if [ -n "$WIN" ]; then
    # If it was already open (and just got minimized), this un-minimizes and focuses it
    wmctrl -ia "$WIN"
else
    # If it wasn't open, launch a fresh instance
    kitty &
fi
