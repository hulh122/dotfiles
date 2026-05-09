alias cc='claude  --dangerously-skip-permissions'
alias ccc='cc --continue'

if [[ -x "$HOME/.cargo/bin/codex-switch" ]]; then
    alias codex-switch="$HOME/.cargo/bin/codex-switch"
fi

codex_claude_compat_init() {
    local repo_root="$PWD"

    rm -rf "$repo_root/.codex"
    mkdir -pv "$repo_root/.codex"
    mkdir -pv "$HOME/.agents/skills"

    if [ -d "$HOME/.config/claude/skills" ]; then
        find "$HOME/.config/claude/skills" -mindepth 1 -maxdepth 1 -type d -exec cp -a {} "$HOME/.agents/skills/" \;
    fi

    if [ -d "$repo_root/.claude/skills" ]; then
        rm -rf "$repo_root/.agents/skills"
        mkdir -pv "$repo_root/.agents/skills"
        cp -a "$repo_root/.claude/skills/." "$repo_root/.agents/skills/"
        cp -a "$repo_root/.claude/skills" "$repo_root/.codex/"
    fi

    if [ -d "$repo_root/.claude/commands" ]; then
        cp -a "$repo_root/.claude/commands" "$repo_root/.codex/"
    fi
}

xx() {
    local codex_switch_bin="${HOME}/.cargo/bin/codex-switch"
    if [[ ! -x "$codex_switch_bin" ]]; then
        codex_switch_bin="$(command -v codex-switch 2>/dev/null)"
    fi

    if [[ -z "$codex_switch_bin" ]] || ! "$codex_switch_bin" --help >/dev/null 2>&1; then
        echo "codex-switch is not installed or cannot run. Run ~/dotfiles/install.sh after installing Rust on macOS." >&2
        return 1
    fi

    codex_claude_compat_init && "$codex_switch_bin" run -- --dangerously-bypass-approvals-and-sandbox "$@"
}

xxx() {
    xx resume --last "$@"
}
