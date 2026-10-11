#!/bin/bash
# One-command setup for a new Mac, before this repository exists locally:
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/joekleinsorge/dotfiles/main/setup/install.sh)"
#
# Installs Apple's command line tools and Nix when missing, clones the
# repository, then hands over to `make`, which bootstraps nix-darwin. Every
# step is skipped when already done, so rerunning it is safe.

set -euo pipefail

repository_url="${DOTFILES_REPO:-https://github.com/joekleinsorge/dotfiles.git}"
dotfiles_dir="${DOTFILES_DIR:-$HOME/git/dotfiles}"

if [ "$(uname -s)" != Darwin ] || [ "$(id -u)" = 0 ]; then
  echo "Run this on macOS from your normal account, without sudo."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Apple's command line tools; finish the dialog that opens."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
fi

nix_profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  echo "Installing Nix with the official multi-user installer."
  installer="$(mktemp)"
  trap 'rm -f "$installer"' EXIT
  curl --proto '=https' --tlsv1.2 -fsSL https://nixos.org/nix/install -o "$installer"
  sh "$installer" --daemon
fi
# shellcheck source=/dev/null
. "$nix_profile"

if [ ! -d "$dotfiles_dir/.git" ]; then
  mkdir -p "$(dirname "$dotfiles_dir")"
  /usr/bin/git clone "$repository_url" "$dotfiles_dir"
fi

exec /usr/bin/make -C "$dotfiles_dir"
