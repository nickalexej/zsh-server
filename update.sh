#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Server Shell Update
# Pulls latest config files from GitHub and applies them.
# ─────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

REPO_RAW="https://raw.githubusercontent.com/nickalexej/zsh-server/main"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

step() { echo -e "\n${BLUE}${BOLD}==> $1${NC}"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

backup() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.bak"
        warn "Backed up $(basename "$file") → $(basename "${file}.bak")"
    fi
}

fetch() {
    local url="$1"
    local dest="$2"

    if ! curl -fsSL "$url" -o "$dest"; then
        echo -e "${RED}[ERR]${NC} Failed to download: $url"
        exit 1
    fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

echo -e "${BLUE}${BOLD}"
echo "╔════════════════════════════════════════╗"
echo "║         Server Shell Update            ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

step "Fetching latest configs from GitHub"

# .zshrc
backup "$HOME/.zshrc"
fetch "$REPO_RAW/config/zshrc" "$HOME/.zshrc"
ok ".zshrc updated"

# p10k
backup "$HOME/.p10k.zsh"
fetch "$REPO_RAW/config/p10k.zsh" "$HOME/.p10k.zsh"
ok ".p10k.zsh updated"

# Aliases
mkdir -p "$ZSH_CUSTOM"
fetch "$REPO_RAW/config/aliases.zsh" "$ZSH_CUSTOM/my-aliases.zsh"
ok "aliases.zsh updated"

# tmux
backup "$HOME/.tmux.conf"
fetch "$REPO_RAW/config/tmux.conf" "$HOME/.tmux.conf"
ok ".tmux.conf updated"

# ─── Reload ──────────────────────────────────────────────────────────────────

step "Reloading configs"

# Reload tmux if a session is running
if command -v tmux &>/dev/null && tmux info &>/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf" && ok "tmux config reloaded"
else
    warn "No active tmux session — restart tmux to apply changes"
fi

echo -e "\n${GREEN}${BOLD}Update complete!${NC}"
echo ""
echo "Apply ZSH changes: exec zsh"
