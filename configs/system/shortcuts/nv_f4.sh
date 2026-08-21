#!/bin/bash

CURRENT_WS=$(wmctrl -d | awk '$2 == "*" {print $1}')

ACTIVE_HEX=$(xprop -root _NET_ACTIVE_WINDOW | grep -o '0x[0-9a-fA-F]*')
ACTIVE_DEC=$([ -n "$ACTIVE_HEX" ] && printf "%d" "$ACTIVE_HEX" || echo "0")

WINS=($(wmctrl -lx | awk -v ws="$CURRENT_WS" '$2 == ws && $3 ~ /NeovimTerm/ {print $1}'))

if [ ${#WINS[@]} -eq 0 ]; then
    wmctrl -k on
    sleep 0.15
    kitty --class NeovimTerm nvim &
else
    NEXT_WIN=${WINS[0]}
    for i in "${!WINS[@]}"; do
        WIN_DEC=$(printf "%d" "${WINS[$i]}")
        if [ "$WIN_DEC" -eq "$ACTIVE_DEC" ]; then
            NEXT_INDEX=$(( (i + 1) % ${#WINS[@]} ))
            NEXT_WIN=${WINS[$NEXT_INDEX]}
            break
        fi
    done
    
    wmctrl -k on
    sleep 0.15
    wmctrl -ia "$NEXT_WIN"
fi
