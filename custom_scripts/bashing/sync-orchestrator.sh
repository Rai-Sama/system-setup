#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$HOME/everything/system/custom_scripts/bashing"

"$SCRIPT_DIR/sync-all-vaults.sh"
"$SCRIPT_DIR/sync-system.sh"
"$SCRIPT_DIR/sync-learning.sh"
