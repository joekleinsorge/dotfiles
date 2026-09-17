#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_repo_root="$(cd "$script_dir/.." && pwd)"
repo_root="${1:-$default_repo_root}"
linuxbrew_bin=""

if [ -z "$repo_root" ] || [ ! -d "$repo_root" ] || [ ! -d "$repo_root/terminal" ]; then
    echo "Usage: bash wsl/setup.sh [repo_root_in_wsl]"
    exit 1
fi

link_path() {
    local source_path="$1"
    local destination_path="$2"

    mkdir -p "$(dirname "$destination_path")"
    rm -rf "$destination_path"
    ln -s "$source_path" "$destination_path"
    echo "Linked $destination_path"
}

load_linuxbrew() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi

    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        linuxbrew_bin=/home/linuxbrew/.linuxbrew/bin/brew
    elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
        linuxbrew_bin="$HOME/.linuxbrew/bin/brew"
    else
        return 1
    fi

    eval "$("$linuxbrew_bin" shellenv)"
    return 0
}

install_apt_prerequisites() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "apt-get not found; skipping Ubuntu package bootstrap."
        return
    fi

    echo "Installing required packages in WSL..."
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        git \
        jq \
        procps \
        software-properties-common \
        tmux \
        unzip \
        zip \
        zsh
}

ensure_linuxbrew() {
    if load_linuxbrew; then
        return
    fi

    echo "Installing Homebrew in WSL..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if ! load_linuxbrew; then
        echo "Homebrew install completed but brew was not found in the expected location."
        exit 1
    fi
}

install_wsl_brew_packages() {
    ensure_linuxbrew
    echo "Installing Homebrew packages in WSL..."
    brew bundle --file="$repo_root/wsl/Brewfile" --no-lock
}

install_command_shims() {
    mkdir -p "$HOME/.local/bin"

    if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi

    if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
}

install_apt_prerequisites
install_wsl_brew_packages
install_command_shims

mkdir -p "$HOME/.config"

link_path "$repo_root/terminal/zsh/.zshrc" "$HOME/.zshrc"
link_path "$repo_root/terminal/nvim" "$HOME/.config/nvim"
link_path "$repo_root/terminal/starship/starship.toml" "$HOME/.config/starship.toml"
link_path "$repo_root/terminal/tmux/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/k9s"
link_path "$repo_root/terminal/k9s/aliases.yaml" "$HOME/.config/k9s/aliases.yaml"
link_path "$repo_root/terminal/k9s/config.yaml" "$HOME/.config/k9s/config.yaml"
link_path "$repo_root/terminal/k9s/plugins.yaml" "$HOME/.config/k9s/plugins.yaml"

if [ -x "$(command -v zsh)" ] && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)" "$USER" || true
fi

echo "WSL setup complete. Restart your WSL shell to pick up Homebrew and shell changes."
