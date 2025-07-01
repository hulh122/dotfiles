# install.sh
#!/usr/bin/env bash
set -eu

dotfiles_dir="$HOME"/dotfiles

# install omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# copy zsh config
ln -sf $dotfiles_dir/.zshrc $HOME/.zshrc

# copy bin file to user/local/bin
ln -sf $dotfiles_dir/bin/dc /usr/local/bin/dc
ln -sf $dotfiles_dir/bin/pull /usr/local/bin/pull
ln -sf $dotfiles_dir/bin/push /usr/local/bin/push

chmod +x /usr/local/bin/dc
chmod +x /usr/local/bin/pull 
chmod +x /usr/local/bin/push