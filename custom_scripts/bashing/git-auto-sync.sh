#!/usr/bin/env bash

set -euo pipefail

REPO_PATH="${1:?Repository path required}"
LOGFILE="${2:?Log file path required}"

SCRIPT_DIR="$HOME/everything/system/custom_scripts/bashing"

source "$SCRIPT_DIR/logger.sh"

if [ ! -d "$REPO_PATH/.git" ]; then
    log "ERROR: $REPO_PATH is not a git repository" "$LOGFILE"
    exit 1
fi

cd "$REPO_PATH"

log "Starting sync for $REPO_PATH" "$LOGFILE"

CURRENT_BRANCH=$(git branch --show-current)

git fetch origin
git pull --rebase origin "$CURRENT_BRANCH" || true

git add .

if ! git diff --cached --quiet; then
    git commit -m "chore: auto-sync $(hostname) $(date '+%Y-%m-%d %H:%M')"
    git push origin "$CURRENT_BRANCH"
    log "Changes committed and pushed" "$LOGFILE"
else
    log "No changes detected" "$LOGFILE"
fi

log "Sync complete for $REPO_PATH" "$LOGFILE"
