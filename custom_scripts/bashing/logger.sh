#!/usr/bin/env bash

# logger.sh
# Usage:
#   source logger.sh
#   log "message" "logfile"

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    local message="${1:?message required}"
    local logfile="${2:?logfile required}"

    echo "$(timestamp): $message" >> "$logfile"
}
