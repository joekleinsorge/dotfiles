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

# The installer has no version option, so pin the script itself. When pi.dev
# changes it, review the new script and update this hash.
pi_installer_sha256=ff4ed7b1ea1c058f33249a44093863b50cf95224ab4ff654e722fcbbbdaa31df

pi_bin="$(command -v pi 2>/dev/null || echo "$HOME/.local/bin/pi")"
if [ ! -x "$pi_bin" ]; then
  echo "Installing pi with its official installer; it updates itself with 'pi update'."
  installer="$(mktemp)"
  trap 'rm -f "$installer"' EXIT
  curl --proto '=https' --tlsv1.2 -fsSL https://pi.dev/install.sh -o "$installer"
  actual="$(shasum -a 256 "$installer" | awk '{print $1}')"
  if [ "$actual" = "$pi_installer_sha256" ]; then
    sh "$installer"
  else
    echo "The pi installer changed (sha256 $actual). Review https://pi.dev/install.sh," >&2
    echo "then update pi_installer_sha256 in setup/agents.sh." >&2
  fi
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
