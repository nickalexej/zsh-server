#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Server Shell Setup
# ZSH + Oh-My-Zsh + Oh My Posh + Plugins + tmux
# ─────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

step()  { echo -e "\n${BLUE}${BOLD}==> $1${NC}"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

need_sudo() {
    [ "$(id -u)" -ne 0 ]
}

run_sudo() {
    if need_sudo; then
        sudo "$@"
    else
        "$@"
    fi
}

# ─── Package Manager Detection ───────────────────────────────────────────────

detect_pkg_manager() {
    if command -v brew &>/dev/null; then
        PKG_INSTALL="brew install"
        PKG_UPDATE="brew update"
    elif command -v apt-get &>/dev/null; then
        PKG_INSTALL="apt-get install -y"
        PKG_UPDATE="apt-get update -qq"
    elif command -v dnf &>/dev/null; then
        PKG_INSTALL="dnf install -y"
        PKG_UPDATE="dnf check-update -q; true"
    elif command -v yum &>/dev/null; then
        PKG_INSTALL="yum install -y"
        PKG_UPDATE="yum check-update -q; true"
    elif command -v pacman &>/dev/null; then
        PKG_INSTALL="pacman -S --noconfirm"
        PKG_UPDATE="pacman -Sy"
    else
        err "No supported package manager found (brew, apt, dnf, yum, pacman)"
    fi
}

# ─── Install Packages ────────────────────────────────────────────────────────

install_packages() {
    step "Checking required packages"

    # brew never runs as root/sudo
    if [ "$PKG_INSTALL" = "brew install" ]; then
        bash -c "$PKG_UPDATE" 2>/dev/null || true
    else
        run_sudo bash -c "$PKG_UPDATE" 2>/dev/null || true
    fi

    local packages=(zsh tmux git curl)
    for pkg in "${packages[@]}"; do
        if command -v "$pkg" &>/dev/null; then
            ok "$pkg already installed"
        else
            step "Installing $pkg..."
            if [ "$PKG_INSTALL" = "brew install" ]; then
                bash -c "$PKG_INSTALL $pkg"
            else
                run_sudo bash -c "$PKG_INSTALL $pkg"
            fi
            ok "$pkg installed"
        fi
    done
}

# ─── ZSH as Default Shell ────────────────────────────────────────────────────

set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [ "$SHELL" = "$zsh_path" ]; then
        ok "ZSH is already the default shell"
        return
    fi

    step "Setting ZSH as default shell"

    # Make sure zsh is in /etc/shells
    if ! grep -qF "$zsh_path" /etc/shells; then
        echo "$zsh_path" | run_sudo tee -a /etc/shells > /dev/null
    fi

    if need_sudo; then
        chsh -s "$zsh_path" "$USER"
    else
        # Running as root — change shell for the invoking user if set
        chsh -s "$zsh_path" root
    fi

    ok "Default shell set to ZSH (takes effect on next login)"
}

# ─── Oh-My-Zsh ───────────────────────────────────────────────────────────────

install_omz() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "Oh-My-Zsh already installed"
        return
    fi

    step "Installing Oh-My-Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "Oh-My-Zsh installed"
}

# ─── Plugins & Theme ─────────────────────────────────────────────────────────

clone_if_missing() {
    local name="$1"
    local url="$2"
    local dest="$3"

    if [ -d "$dest" ]; then
        ok "$name already installed"
    else
        step "Installing $name"
        git clone --depth=1 "$url" "$dest"
        ok "$name installed"
    fi
}

install_plugins() {
    clone_if_missing "zsh-autosuggestions" \
        "https://github.com/zsh-users/zsh-autosuggestions" \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

    clone_if_missing "zsh-syntax-highlighting" \
        "https://github.com/zsh-users/zsh-syntax-highlighting" \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
}

# ─── Oh My Posh ──────────────────────────────────────────────────────────────

install_omp() {
    if command -v oh-my-posh &>/dev/null; then
        ok "oh-my-posh already installed"
        return
    fi

    step "Installing oh-my-posh"
    mkdir -p "$HOME/.local/bin"

    local omp_asset
    case "$(uname -s)" in
        Darwin)
            if [ "$(uname -m)" != "arm64" ]; then
                warn "Unsupported arch for oh-my-posh on macOS: $(uname -m) (only Apple Silicon supported)"
                return
            fi
            omp_asset="posh-darwin-arm64"
            ;;
        Linux)
            local omp_arch
            case "$(uname -m)" in
                x86_64)  omp_arch="amd64"  ;;
                aarch64) omp_arch="arm64"  ;;
                armv7l)  omp_arch="arm"    ;;
                *) warn "Unsupported arch for oh-my-posh: $(uname -m)"; return ;;
            esac
            omp_asset="posh-linux-${omp_arch}"
            ;;
        *)
            warn "Unsupported OS for oh-my-posh: $(uname -s)"; return ;;
    esac

    curl -fsSL "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/${omp_asset}" \
        -o "$HOME/.local/bin/oh-my-posh"
    chmod +x "$HOME/.local/bin/oh-my-posh"
    ok "oh-my-posh installed"
}

# ─── Copy Config Files ───────────────────────────────────────────────────────

backup() {
    local file="$1"
    if [ -f "$file" ] && [ ! -f "${file}.bak" ]; then
        cp "$file" "${file}.bak"
        warn "Backed up $(basename "$file") → $(basename "${file}.bak")"
    fi
}

copy_configs() {
    step "Copying config files"

    # .zshrc
    backup "$HOME/.zshrc"
    cp "$CONFIG_DIR/zshrc" "$HOME/.zshrc"
    ok ".zshrc installed"

    # Aliases
    mkdir -p "$ZSH_CUSTOM"
    cp "$CONFIG_DIR/aliases.zsh" "$ZSH_CUSTOM/my-aliases.zsh"
    ok "aliases.zsh installed → $ZSH_CUSTOM/my-aliases.zsh"

    # tmux
    backup "$HOME/.tmux.conf"
    cp "$CONFIG_DIR/tmux.conf" "$HOME/.tmux.conf"
    ok ".tmux.conf installed"

    # oh-my-posh theme
    mkdir -p "$HOME/.config/ohmyposh"
    backup "$HOME/.config/ohmyposh/server.toml"
    cp "$CONFIG_DIR/omp.toml" "$HOME/.config/ohmyposh/server.toml"
    ok "omp theme installed → ~/.config/ohmyposh/server.toml"
}

# ─── Glow (Markdown Renderer) ────────────────────────────────────────────────

install_glow() {
    if command -v glow &>/dev/null; then
        ok "glow already installed"
        return
    fi

    step "Installing glow (markdown renderer)"

    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64)  arch="x86_64" ;;
        aarch64) arch="arm64"  ;;
        armv7l)  arch="armv7"  ;;
        *)
            warn "Unsupported architecture for glow: $arch — skipping"
            return
            ;;
    esac

    local os
    os="$(uname -s)"
    case "$os" in
        Linux)  os="Linux"  ;;
        Darwin) os="Darwin" ;;
        *)
            warn "Unsupported OS for glow: $os — skipping"
            return
            ;;
    esac

    local version
    version="$(curl -fsSL https://api.github.com/repos/charmbracelet/glow/releases/latest \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')"

    if [ -z "$version" ]; then
        warn "Could not fetch latest glow version — skipping"
        return
    fi

    local url="https://github.com/charmbracelet/glow/releases/download/v${version}/glow_${version}_${os}_${arch}.tar.gz"
    local tmp
    tmp="$(mktemp -d)"

    if ! curl -fsSL "$url" | tar -xz -C "$tmp"; then
        warn "Failed to download or extract glow — skipping"
        rm -rf "$tmp"
        return
    fi

    local glow_bin
    glow_bin="$(find "$tmp" -type f -name "glow" | head -1)"

    if [ -z "$glow_bin" ]; then
        warn "glow binary not found after extraction — skipping"
        rm -rf "$tmp"
        return
    fi

    run_sudo mv "$glow_bin" /usr/local/bin/glow
    run_sudo chmod +x /usr/local/bin/glow
    rm -rf "$tmp"

    ok "glow ${version} installed"
}

# ─── tmux Plugin Manager (tpm) ───────────────────────────────────────────────

install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        ok "tpm already installed"
        return
    fi

    step "Installing tmux plugin manager (tpm)"
    mkdir -p "$HOME/.tmux/plugins"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    ok "tpm installed"
}

# ─── Main ────────────────────────────────────────────────────────────────────

main() {
    echo -e "${BLUE}${BOLD}"
    echo "╔════════════════════════════════════════╗"
    echo "║         Server Shell Setup             ║"
    echo "║    ZSH · Oh-My-Zsh · Oh My Posh       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}WARNING:${NC} You are running as root."
        echo "This will install everything into /root/ instead of your user home."
        echo "Run without sudo: ${BOLD}./setup.sh${NC}"
        echo ""
        read -r -p "Continue anyway as root? [y/N] " confirm
        [[ "$confirm" =~ ^[yY]$ ]] || exit 1
    fi

    detect_pkg_manager
    install_packages
    set_default_shell
    install_omz
    install_plugins
    install_omp
    copy_configs
    install_glow
    install_tpm

    echo -e "\n${GREEN}${BOLD}Setup complete!${NC}\n"
    echo "Next steps:"
    echo "  1. Start ZSH:               exec zsh"
    echo "  2. Install tmux plugins:    tmux, then Ctrl+a + I"
}

main "$@"
