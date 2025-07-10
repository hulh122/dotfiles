#!/usr/bin/env bash

set -e

dotfiles_dir="$HOME"/dotfiles

# Link dotfiles
mkdir -p "$HOME"/.config
mkdir -p ~/.local/bin
rm -rf "$HOME"/.{zshrc,zprofile,profile,bashrc,bash_logout}
ln -sf $dotfiles_dir/.zshenv $HOME/.zshenv
ln -sf $dotfiles_dir/.gitignore.global $HOME/.gitignore.global
ln -sf $dotfiles_dir/.gitconfig $HOME/.gitconfig
ln -sf $dotfiles_dir/.gitattributes $HOME/.gitattributes
ln -sf $dotfiles_dir/.agignore $HOME/.agignore
cp -a "$dotfiles_dir/.config/zsh" "$HOME/.config/zsh"

# Setup zsh configuration
echo "Setting up zsh configuration..."

# Set XDG_CONFIG_HOME if not already set
if [[ -z "$XDG_CONFIG_HOME" ]]; then
    export XDG_CONFIG_HOME="$HOME/.config/"
    echo "Set XDG_CONFIG_HOME to: $XDG_CONFIG_HOME"
fi

# Set ZDOTDIR if zsh config directory exists
if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
    echo "Set ZDOTDIR to: $ZDOTDIR"
fi

# Add environment variables to /etc/zprofile
echo "Adding environment variables to /etc/zprofile..."
cat << EOF | sudo tee -a /etc/zprofile > /dev/null

if [[ -z "\$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="\$HOME/.config/"
fi

if [[ -d "\$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="\$XDG_CONFIG_HOME/zsh/"
fi
EOF

echo "zsh configuration setup completed"

if command -v vim >/dev/null 2>&1; then
    echo "Installing vim configuration..."
    curl https://raw.githubusercontent.com/e7h4n/e7h4n-vim/master/bootstrap.sh -L -o - | sh
    echo "vim configuration installation completed"
fi

# Install zimfw (zsh framework)
echo "Installing zimfw..."
rm -rf ${ZDOTDIR:-${HOME}}/.zim
git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim
echo "zimfw installation completed"

echo "Installing claude code..."
sudo npm install -g @anthropic-ai/claude-code

echo "All setup completed successfully!"
