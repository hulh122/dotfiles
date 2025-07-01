# install.sh
#!/usr/bin/env bash
set -eu

dotfiles_dir="$HOME"/dotfiles

# install omz (with --unattended flag to prevent starting new shell)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# copy zsh config
ln -sf $dotfiles_dir/.zshrc $HOME/.zshrc
source $HOME/.zshrc

# copy bin file to user/local/bin
sudo cp $dotfiles_dir/bin/dc /usr/local/bin
sudo cp $dotfiles_dir/bin/pull /usr/local/bin
sudo cp $dotfiles_dir/bin/push /usr/local/bin

sudo chmod +x /usr/local/bin/dc
sudo chmod +x /usr/local/bin/pull 
sudo chmod +x /usr/local/bin/push

echo "安装完成！请运行 'exec zsh' 或重新打开终端来使用新的shell配置。"
