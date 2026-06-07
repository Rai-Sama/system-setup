#!/usr/bin/env bash

set -euo pipefail

REPO_PATH="${1:?Repository path required}"
LOGFILE="${2:?Log file path required}"

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    echo "$(timestamp): $1" >> "$LOGFILE"
}

if [ ! -d "$REPO_PATH/.git" ]; then
    log "ERROR: $REPO_PATH is not a git repository"
    exit 1
fi

cd "$REPO_PATH"

log "Starting sync"

CURRENT_BRANCH=$(git branch --show-current)

git fetch origin
git pull --rebase origin "$CURRENT_BRANCH" || true

git add .

if ! git diff --cached --quiet; then
    git commit -m "chore: auto-sync $(hostname) $(date '+%Y-%m-%d %H:%M')"
    git push origin "$CURRENT_BRANCH"
    log "Changes committed and pushed"
else
    log "No changes detected"
fi

log "Sync complete"
