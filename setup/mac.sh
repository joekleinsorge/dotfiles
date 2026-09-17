#!/bin/bash

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

if ! command -v nix >/dev/null 2>&1 && [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  echo "Nix is not installed. Install it from https://nixos.org/download/ and rerun this script."
  exit 1
fi

nix_bin="$(command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)"

if [ ! -f "$dotfiles_dir/flake.lock" ]; then
  echo "flake.lock is missing. Restore it before bootstrapping."
  exit 1
fi

# shellcheck source=setup/preflight-mac.sh
source "$dotfiles_dir/setup/preflight-mac.sh"
darwin_rev="$(/usr/bin/plutil -extract nodes.darwin.locked.rev raw "$dotfiles_dir/flake.lock")"

if [ "$(whoami)" != "$configured_user" ]; then
  echo "This flake is configured for macOS user '$configured_user', but the current user is '$(whoami)'."
  echo "Update dotfilesConfig in flake.nix before bootstrapping."
  exit 1
fi

# Build successfully before moving any existing configuration files.
"$nix_bin" --extra-experimental-features 'nix-command flakes' build \
  --no-update-lock-file --no-link "$dotfiles_dir#darwinConfigurations.$configured_host-bootstrap.system"

# The Nix installer prepends its daemon initialization to Apple's stock shell
# files. nix-darwin needs to own these paths, so preserve the originals before
# the first activation. Never overwrite an existing backup.
for shell_file in /etc/bashrc /etc/zshrc; do
  backup_file="${shell_file}.before-nix-darwin"
  if [ -e "$shell_file" ] && [ ! -L "$shell_file" ]; then
    if [ -e "$backup_file" ]; then
      echo "Cannot back up $shell_file because $backup_file already exists."
      echo "Review those files and resolve the conflict before continuing."
      exit 1
    fi
    echo "Preserving $shell_file as $backup_file"
    sudo mv "$shell_file" "$backup_file"
  fi
done

bash "$dotfiles_dir/setup/migrate-k9s.sh"

sudo -H "$nix_bin" --extra-experimental-features "nix-command flakes" \
  run "github:LnL7/nix-darwin/$darwin_rev#darwin-rebuild" -- \
  switch --flake "$dotfiles_dir#$configured_host-bootstrap" --no-write-lock-file

echo "Bootstrap complete. Use ./rebuild.sh for future changes."
