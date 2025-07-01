# install.sh
#!/usr/bin/env bash
set -eu

dotfiles_dir="$HOME"/dotfiles

# install omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# copy zsh config
ln -sf $dotfiles_dir/.zshrc $HOME/.zshrc


# copy bin file to user/local/bin
sudo cp $dotfiles_dir/bin/dc /usr/local/bin
sudo cp $dotfiles_dir/bin/pull /usr/local/bin
sudo cp $dotfiles_dir/bin/push /usr/local/bin

sudo chmod +x /usr/local/bin/dc
sudo chmod +x /usr/local/bin/pull 
sudo chmod +x /usr/local/bin/push
