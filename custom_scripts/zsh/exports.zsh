export PATH="$HOME/everything/system/custom_scripts/bashing:$PATH"

export ZSH="$HOME/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"

export ATUIN_NOBIND="true"

# ==========================================
# FZF (Fuzzy Finder) Configuration
# ==========================================
# Tokyo Night Color Palette
export FZF_DEFAULT_OPTS=" \
--color=bg+:#24283b,bg:#1a1b26,spinner:#ff007c,hl:#565f89 \
--color=fg:#c0caf5,header:#565f89,info:#0db9d7,pointer:#7aa2f7 \
--color=marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7aa2f7"

# Use fd-find for lightning-fast file searching
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git --exclude node_modules --exclude __pycache__'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
