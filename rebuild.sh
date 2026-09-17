#!/usr/bin/env bash

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
nix_bin="$(command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)"
darwin_rebuild_bin="$(command -v darwin-rebuild 2>/dev/null || echo /run/current-system/sw/bin/darwin-rebuild)"

if [ ! -f "$dotfiles_dir/flake.lock" ]; then
  echo "flake.lock is missing. Restore it or run 'make update' deliberately."
  exit 1
fi

# shellcheck source=setup/preflight-mac.sh
source "$dotfiles_dir/setup/preflight-mac.sh"

bash "$dotfiles_dir/setup/migrate-k9s.sh"

exec sudo -H "$darwin_rebuild_bin" switch \
  --flake "$dotfiles_dir#$configured_host" --no-write-lock-file
