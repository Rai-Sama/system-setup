#!/bin/bash

CURRENT_WS=$(wmctrl -d | awk '$2 == "*" {print $1}')

WIN=$(wmctrl -lx | \
      awk -v ws="$CURRENT_WS" '$2 == ws && tolower($3) == "brave-browser.brave-browser" {print $1; exit}')

if [ -n "$WIN" ]; then
    wmctrl -ia "$WIN"
else
    brave-browser --force-device-scale-factor=2.5 --new-window &
fi
