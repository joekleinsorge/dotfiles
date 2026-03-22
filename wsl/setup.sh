#!/usr/bin/env bash

set -euo pipefail

repo_root="${1:-}"

if [ -z "$repo_root" ] || [ ! -d "$repo_root" ]; then
    echo "Usage: bash wsl/setup.sh <repo_root_in_wsl>"
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

if command -v apt-get >/dev/null 2>&1; then
    echo "Installing required packages in WSL..."
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        curl \
        fd-find \
        fzf \
        git \
        jq \
        neovim \
        ripgrep \
        tmux \
        unzip \
        zsh
fi

mkdir -p "$HOME/.config"

link_path "$repo_root/terminal/zsh/.zshrc" "$HOME/.zshrc"
link_path "$repo_root/terminal/nvim" "$HOME/.config/nvim"
link_path "$repo_root/terminal/starship/starship.toml" "$HOME/.config/starship.toml"
link_path "$repo_root/terminal/tmux/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/k9s"
link_path "$repo_root/terminal/k9s/aliases.yaml" "$HOME/.config/k9s/aliases.yaml"
link_path "$repo_root/terminal/k9s/config.yaml" "$HOME/.config/k9s/config.yaml"
link_path "$repo_root/terminal/k9s/plugins.yaml" "$HOME/.config/k9s/plugins.yaml"

if ! command -v starship >/dev/null 2>&1; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if [ -x "$(command -v zsh)" ] && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)" "$USER" || true
fi

echo "WSL setup complete. Restart your WSL shell to pick up shell changes."
