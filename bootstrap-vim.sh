#!/usr/bin/env bash

############################  SETUP PARAMETERS
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/e7h4n/e7h4n-vim.git'
[ -z "$REPO_BRANCH" ] && REPO_BRANCH='main'
debug_mode='0'

############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

############################ SETUP FUNCTIONS

do_backup() {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ]; then
        msg "Attempting to back up your original vim configuration."
        today=`date +%Y%m%d_%s`
        for i in "$1" "$2" "$3"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today";
        done
        ret="$?"
        success "Your original neovim configuration has been backed up."
        debug
   fi
}

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi

    # Fix line endings and encoding issues
    msg "Fixing line endings for vimrc..."
    if [ -f "$repo_path/vimrc" ]; then
        # Convert CRLF to LF and ensure UTF-8 encoding
        dos2unix "$repo_path/vimrc" 2>/dev/null || sed -i 's/\r$//' "$repo_path/vimrc"
        success "Line endings fixed."
    fi

    debug
}

install() {
    msg "Downloading vim-plug..."
    mkdir -p ~/.local/share/vim/autoload
    curl -fLo ~/.local/share/vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        error "Failed to download vim-plug"
    fi
    success "vim-plug downloaded successfully"

    msg "=== Vim environment check ==="
    msg "Vim version:"
    vim --version | head -1
    msg ""
    msg "VIMRC location: ~/.config/vim/vimrc"
    if [ -f ~/.config/vim/vimrc ]; then
        msg "✓ vimrc file exists"
        msg "Complete vimrc file (for debugging):"
        cat ~/.config/vim/vimrc | sed 's/^/  /'
    else
        msg "✗ vimrc file not found!"
    fi
    msg ""
    msg "vim-plug location: ~/.local/share/vim/autoload/plug.vim"
    if [ -f ~/.local/share/vim/autoload/plug.vim ]; then
        msg "✓ plug.vim exists ($(wc -l < ~/.local/share/vim/autoload/plug.vim) lines)"
    else
        msg "✗ plug.vim not found!"
    fi
    msg ""

    msg "Running PlugInstall and PlugClean..."
    msg "Executing: vim -u ~/.config/vim/vimrc +PlugInstall! +PlugClean +qall!"
    vim -u ~/.config/vim/vimrc +PlugInstall! +PlugClean +qall!
    ret="$?"
    msg "Vim exit code: $ret"
    if [ "$ret" -ne 0 ]; then
        msg "Warning: vim exited with code $ret. This might be normal if plugins installed successfully."
    fi
    success "Vim plugin installation completed"
}

############################ MAIN()
variable_set "$HOME"
program_must_exist "vim"
program_must_exist "git"

do_backup       "$HOME/vim"

sync_repo       "$HOME/.config/vim" \
                "$REPO_URI" \
                "$REPO_BRANCH" \
                "e7h4n-vim"

install

success         "Done."
