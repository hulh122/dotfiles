alias cc='claude  --dangerously-skip-permissions'
alias ccc='cc --continue'

xx() {
    codex --dangerously-bypass-approvals-and-sandbox "$@"
}

xxx() {
    xx resume --last "$@"
}

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

cdc() {
    codex_claude_compat_init && xx "$@"
}

cdcc() {
    codex_claude_compat_init && xxx "$@"
}
