#!/usr/bin/env bash

SCRIPT_DIR="$HOME/everything/system/custom_scripts/bashing"

"$SCRIPT_DIR/git-auto-sync.sh" \
    "$HOME/everything/system" \
    "$HOME/everything/system/logging/system_sync.log"
