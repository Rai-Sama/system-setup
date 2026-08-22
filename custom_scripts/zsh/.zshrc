# Only run fastfetch if the terminal window is wider than 70 columns and taller than 15 lines
if [[ $LINES -gt 15 && $COLUMNS -gt 70 ]]; then
    fastfetch
fi

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/everything/system/custom_scripts/zsh/exports.zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

source ~/everything/system/custom_scripts/zsh/history.zsh
source ~/everything/system/custom_scripts/zsh/aliases.zsh
source ~/everything/system/custom_scripts/zsh/tools.zsh
source ~/everything/system/custom_scripts/zsh/functions.zsh

# Source untracked local environment variables and secrets
if [[ -f "$HOME/.local_secrets" ]]; then
    source "$HOME/.local_secrets"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Integrating zoxide as an improved alternative to cd
eval "$(zoxide init zsh)"
alias cd='z'
