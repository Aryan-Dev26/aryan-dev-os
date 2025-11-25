export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"   # you can try other themes later: robbyrussell, bira, etc.

plugins=(
  git
  docker
)

source $ZSH/oh-my-zsh.sh

# --- Aryan custom stuff ---

# Better ls
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'

# Node + web
alias nr='npm run'
alias y='yarn'
alias pn='pnpm'

# Docker shortcuts
alias dps='docker ps'
alias dimg='docker images'
alias dco='docker compose'

# Path / editor
export EDITOR="nano"

# NVM (ensure it's loaded in zsh)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
