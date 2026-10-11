#!/usr/bin/env bash
# Installs the agent tooling that manages its own updates and restores the
# plugin and package lists tracked in agents/. Claude Code and Codex come from
# Homebrew casks in nix/darwin.nix; their guidance and skills are linked by
# Home Manager. Safe to rerun: only missing items are installed.

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

if [ "$(id -u)" = 0 ]; then
  echo "Run this from your normal account, without sudo."
  exit 1
fi

# Prints the entries of a list file, skipping comments and blank lines.
entries() {
  grep -vE '^[[:space:]]*(#|$)' "$1"
}

pi_bin="$(command -v pi 2>/dev/null || echo "$HOME/.local/bin/pi")"
if [ ! -x "$pi_bin" ]; then
  echo "Installing pi with its official installer; it updates itself with 'pi update'."
  curl -fsSL https://pi.dev/install.sh | sh
fi
if [ -x "$pi_bin" ]; then
  installed="$("$pi_bin" list 2>/dev/null | awk '{print $1}')"
  entries "$dotfiles_dir/agents/pi-packages.txt" | while read -r package; do
    if ! printf '%s\n' "$installed" | grep -qxF "$package"; then
      "$pi_bin" install "$package"
    fi
  done
else
  echo "pi was not found after installation; skipping pi packages."
fi

if command -v claude >/dev/null 2>&1; then
  installed="$(claude plugin list 2>/dev/null | grep -oE '[^[:space:]]+@[^[:space:]]+' || true)"
  entries "$dotfiles_dir/agents/claude-plugins.txt" | while read -r plugin; do
    if ! printf '%s\n' "$installed" | grep -qxF "$plugin"; then
      claude plugin install "$plugin"
    fi
  done
else
  echo "Claude Code is not installed yet; rerun 'make agents' after 'make'."
fi
