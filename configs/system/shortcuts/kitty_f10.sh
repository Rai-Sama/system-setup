#!/bin/bash

CURRENT_WS=$(wmctrl -d | awk '$2 == "*" {print $1}')

WIN=$(wmctrl -lx | \
      awk -v ws="$CURRENT_WS" '$2 == ws && $3 == "kitty.kitty" {print $1; exit}')

if [ -n "$WIN" ]; then
    wmctrl -ia "$WIN"
else
    kitty &
fi
