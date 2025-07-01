export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

export http_proxy=http://sg-squid-test.zhenguanyu.com:80
export https_proxy=http://sg-squid-test.zhenguanyu.com:80

alias c="clear"
alias a="git add -A"
alias s="pnpm start"
alias pi="pnpm i"
alias web="cd /workspaces/moxt/web"
alias editor="cd /workspaces/moxt/editor"
# pnpm
export PNPM_HOME="/Users/yuma/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

nvm use 22.4.0

. "$HOME/.local/bin/env"