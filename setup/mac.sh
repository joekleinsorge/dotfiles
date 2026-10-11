#!/bin/bash

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

# shellcheck source=setup/preflight-mac.sh
source "$dotfiles_dir/setup/preflight-mac.sh"
darwin_rev="$(/usr/bin/plutil -extract nodes.darwin.locked.rev raw "$dotfiles_dir/flake.lock")"

# Build successfully before moving any existing configuration files.
env "${dotfiles_env[@]}" "$nix_bin" --extra-experimental-features 'nix-command flakes' build \
  --impure --no-update-lock-file --no-link \
  "$dotfiles_dir#darwinConfigurations.$flake_profile-bootstrap.system"

bash "$dotfiles_dir/setup/adopt-etc.sh"
bash "$dotfiles_dir/setup/migrate-k9s.sh"
bash "$dotfiles_dir/setup/migrate-agents.sh"

sudo -H env "${dotfiles_env[@]}" "$nix_bin" --extra-experimental-features "nix-command flakes" \
  run "github:LnL7/nix-darwin/$darwin_rev#darwin-rebuild" -- \
  switch --flake "$dotfiles_dir#$flake_profile-bootstrap" --impure --no-write-lock-file

# Agent CLIs that manage themselves run as the normal user after activation.
# A network failure here must not undo a completed system setup.
bash "$dotfiles_dir/setup/agents.sh" ||
  echo "Agent setup did not finish; rerun it later with 'make agents'."

echo "Bootstrap complete. Reopen your terminal, then use 'make' for future changes."
