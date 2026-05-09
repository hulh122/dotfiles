# ~/.zshenv should only be a one-liner that sources this file
# echo "source ~/.config/zsh/.zshenv" >| ~/.zshenv

# Skip global compinit by ubuntu
skip_global_compinit=1

export XDG_CONFIG_HOME=~/.config
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
export PATH="$HOME/.cargo/bin:$PATH"
