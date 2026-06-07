#!/usr/bin/env bash
# sync-all-vaults.sh
# Description: Initialize and sync all Obsidian vaults under ~/everything/notes
# Usage: ~/bin/sync-all-vaults.sh
# Cron example (hourly): 0 * * * * /home/raisama/bin/sync-all-vaults.sh >> /home/raisama/obsidian_sync.log 2>&1

BASE_DIR="$HOME/everything/notes"
GITHUB_USER="rai-sama"

SCRIPT_DIR="$HOME/everything/system/custom_scripts/bashing"
source "$SCRIPT_DIR/logger.sh"

LOGFILE="$HOME/everything/system/logging/obsidian_sync.log"

# Ensure gh CLI is installed
if ! command -v gh >/dev/null 2>&1; then
  log "ERROR: gh CLI is not installed. Aborting." "$LOGFILE"
  exit 1
fi

# Iterate over each vault directory
for vault_path in "$BASE_DIR"/*/; do
  [ -d "$vault_path" ] || continue
  vault_name=$(basename "$vault_path")
  repo_name="${vault_name}-notes"
  cd "$vault_path" || continue

  log "Processing vault '$vault_name'..." "$LOGFILE"

  # 1. Initialize git if missing
  if [ ! -d ".git" ]; then
    git init
    echo ".obsidian/" > .gitignore
    git add .gitignore
    git commit -m "chore: initial .gitignore for $vault_name"
    log "Initialized git repo and .gitignore" "$LOGFILE"
  fi

  # 2. Ensure .obsidian/ is ignored
  if ! grep -qx ".obsidian/" .gitignore; then
    echo ".obsidian/" >> .gitignore
    git add .gitignore
    git commit -m "chore: update .gitignore to ignore .obsidian/"
    log "Updated .gitignore" "$LOGFILE"
  fi

  # 3. Add or verify remote origin
  if ! git remote | grep -q origin; then
    # Create remote if it doesn't exist
    if ! gh repo view "${GITHUB_USER}/${repo_name}" >/dev/null 2>&1; then
      gh repo create "${GITHUB_USER}/${repo_name}" --private --source=. --remote=origin
      log "Created remote repo ${repo_name}" "$LOGFILE"
    else
      git remote add origin "git@github.com:${GITHUB_USER}/${repo_name}.git"
      log "Added existing remote origin" "$LOGFILE"
    fi
  fi

  # 4. Pull remote changes (if any)
  git pull --rebase origin main 2>/dev/null || git pull --rebase origin master 2>/dev/null || true
  log "Pulled remote changes" "$LOGFILE"

  # 5. Add, commit, and push local changes
  git add .
  if ! git diff --cached --quiet; then
    git commit -m "chore: sync vault '$vault_name' at $(date '+%Y-%m-%d %H:%M')"
    git push -u origin HEAD
    log "Pushed changes" "$LOGFILE"
  else
    log "No changes to commit" "$LOGFILE"
  fi

done

