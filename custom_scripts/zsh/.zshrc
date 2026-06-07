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

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
