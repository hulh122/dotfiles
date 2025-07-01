# install.sh
#!/usr/bin/env bash
set -eu

dotfiles_dir="$HOME"/dotfiles

# install omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# copy zsh config
ln -sf $dotfiles_dir/.zshrc $HOME/.zshrc