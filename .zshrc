export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

export http_proxy=http://sg-squid-test.zhenguanyu.com:80
export https_proxy=http://sg-squid-test.zhenguanyu.com:80

alias c="clear"
alias a="git add -A"
alias s="pnpm start"
alias pi="pnpm i"
alias web="cd /workspaces/moxt/web"
alias editor="cd /workspaces/moxt/editor"