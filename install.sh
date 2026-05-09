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

    pnpm install -g @charmland/crush ccusage @openai/codex
fi

# Install codex-switch
if ! command -v codex-switch >/dev/null 2>&1 || ! codex-switch --help >/dev/null 2>&1; then
    echo "Installing codex-switch..."
    OS=$(uname -s)
    ARCH=$(uname -m)
    case "$OS:$ARCH" in
        Linux:x86_64) CODEX_SWITCH_ASSET="codex-switch-x86_64-unknown-linux-musl" ;;
        Linux:aarch64|Linux:arm64) CODEX_SWITCH_ASSET="codex-switch-aarch64-unknown-linux-musl" ;;
        Darwin:*)
            if ! command -v cargo >/dev/null 2>&1; then
                echo "codex-switch does not publish macOS binaries. Install Rust first, then rerun this script:"
                echo "  brew install rust"
                echo "or:"
                echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
                exit 1
            fi
            cargo install --git https://github.com/seven332/codex-switch --locked
            sudo install -m 0755 "$HOME/.cargo/bin/codex-switch" /usr/local/bin/codex-switch
            ;;
        *) echo "Unsupported platform for codex-switch: $OS $ARCH"; exit 1 ;;
    esac

    if [[ -n "${CODEX_SWITCH_ASSET:-}" ]]; then
        CODEX_SWITCH_TMP=$(mktemp)
        curl -fsSL -o "$CODEX_SWITCH_TMP" "https://github.com/seven332/codex-switch/releases/latest/download/${CODEX_SWITCH_ASSET}"
        sudo install -m 0755 "$CODEX_SWITCH_TMP" /usr/local/bin/codex-switch
        rm -f "$CODEX_SWITCH_TMP"
    fi
fi

# Install Claude Code statusline
echo "Installing Claude Code statusline..."
mkdir -p "$HOME/.claude"
cp "$dotfiles_dir/.claude/statusline.sh" "$HOME/.claude/statusline.sh"
chmod +x "$HOME/.claude/statusline.sh"
# Merge statusLine config into settings.json (preserve existing settings)
if [ -f "$HOME/.claude/settings.json" ]; then
  echo '{"statusLine":{"type":"command","command":"~/.claude/statusline.sh"}}' | \
    jq -s '.[0] * .[1]' "$HOME/.claude/settings.json" - > "$HOME/.claude/settings.json.tmp" && \
    mv "$HOME/.claude/settings.json.tmp" "$HOME/.claude/settings.json"
else
  echo '{"statusLine":{"type":"command","command":"~/.claude/statusline.sh"}}' > "$HOME/.claude/settings.json"
fi

# Install Claude Code with custom settings
echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | \
  sed -e 's|DOWNLOAD_DIR="\$HOME/.claude/downloads"|DOWNLOAD_DIR="$HOME/.cache/claude"|' \
      -e 's|"\$binary_path" install.*|"\$binary_path" install \$version|' \
      -e '/rm -f "\$binary_path"/d' \
      -e '/version=\$(download_file.*latest")/a echo claude code version: $version' \
      -e 's|if ! download_file|if [ -f "\$binary_path" ]; then echo "Using cached binary"; elif ! download_file|' | \
  bash

# Install zoxide via curl
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Install zimfw (zsh framework)
echo "Installing zimfw..."
rm -rf ${ZDOTDIR:-${HOME}}/.zim
git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim

zsh -c "source ${ZDOTDIR:-${HOME}}/.zim/zimfw.zsh init -q && zimfw install"

# Install vim configuration
if command -v vim >/dev/null 2>&1; then
echo "Installing vim configuration..."
curl https://raw.githubusercontent.com/e7h4n/e7h4n-vim/master/bootstrap.sh -L -o - | bash -i
echo "vim configuration installation completed"
fi
