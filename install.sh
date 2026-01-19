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
cp -a "$dotfiles_dir/.config/zsh/." "$HOME/.config/zsh"
ln -sf "$dotfiles_dir/.config/nvim" "$HOME/.config/nvim"

# Install custom bin scripts
echo "Installing custom bin scripts to ~/.local/bin..."
cp "$dotfiles_dir/bin/"* ~/.local/bin/
chmod +x ~/.local/bin/push ~/.local/bin/pull ~/.local/bin/dc

export XDG_CONFIG_HOME="$HOME/.config/"

# Set ZDOTDIR if zsh config directory exists
if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi

# Add environment variables to /etc/zprofile (requires sudo)
if sudo -n true 2>/dev/null; then
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
else
    echo "Skipping /etc/zprofile modification (no sudo access)"
fi

echo "Setup pnpm..."
if command -v pnpm >/dev/null 2>&1; then
    SHELL=zsh pnpm setup

    export PNPM_HOME="$HOME/.local/share/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    pnpm install -g @anthropic-ai/claude-code @charmland/crush
fi

# Install zoxide via curl
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

echo "Installing vim configuration..."
curl https://raw.githubusercontent.com/e7h4n/e7h4n-vim/master/bootstrap.sh -L -o - | bash -i
echo "vim configuration installation completed"

# Install zimfw (zsh framework)
echo "Installing zimfw..."
rm -rf ${ZDOTDIR:-${HOME}}/.zim
git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim

zsh -c "source ${ZDOTDIR:-${HOME}}/.zim/zimfw.zsh init -q && zimfw install"
