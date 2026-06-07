# NVM
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Conda lazy loading
conda() {
    unset -f conda
    source ~/miniconda3/etc/profile.d/conda.sh
    conda "$@"
}

# Atuin
. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

bindkey '^R' atuin-search
