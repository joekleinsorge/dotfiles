#!/usr/bin/env bash

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
darwin_rebuild_bin="$(command -v darwin-rebuild 2>/dev/null || echo /run/current-system/sw/bin/darwin-rebuild)"

# shellcheck source=setup/preflight-mac.sh
source "$dotfiles_dir/setup/preflight-mac.sh"

bash "$dotfiles_dir/setup/adopt-etc.sh"
bash "$dotfiles_dir/setup/migrate-k9s.sh"
bash "$dotfiles_dir/setup/migrate-agents.sh"

exec sudo -H env "${dotfiles_env[@]}" "$darwin_rebuild_bin" switch \
  --flake "$dotfiles_dir#$flake_profile" --impure --no-write-lock-file
