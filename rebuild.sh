#!/usr/bin/env bash
# Builds and applies the macOS configuration. The same path serves the first
# run (bootstrap) and every later rebuild:
#
#   1. Build as the normal user, so a broken configuration never needs sudo.
#   2. Show what changes: Nix packages, and Homebrew packages to be removed.
#   3. Ask before removing Homebrew packages, then activate with sudo.
#
# DOTFILES_DIFF_ONLY=1 stops after step 2 (`make diff`). DOTFILES_YES=1 skips
# the confirmation, for non-interactive use.

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=setup/preflight-mac.sh
source "$dotfiles_dir/setup/preflight-mac.sh"

echo "Building the '$flake_profile' configuration..."
system="$(env "${dotfiles_env[@]}" "$nix_bin" --extra-experimental-features 'nix-command flakes' \
  build --impure --no-link --print-out-paths --no-write-lock-file \
  "$dotfiles_dir#darwinConfigurations.$flake_profile.system")"

first_run=false
if [ -e /run/current-system ]; then
  echo
  echo "Package changes:"
  changes="$("$nix_bin" --extra-experimental-features nix-command \
    store diff-closures /run/current-system "$system")"
  printf '%s\n' "${changes:-  none}"
else
  first_run=true
fi

# Preview the Homebrew cleanup that activation runs, when the profile has one.
removals=""
brewfile="$(grep -o -- '--file=/nix/store/[^ ]*-Brewfile' "$system/activate" | head -n 1 || true)"
brewfile="${brewfile#--file=}"
if [ -n "$brewfile" ] && [ -x /opt/homebrew/bin/brew ]; then
  preview="$(HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew bundle cleanup \
    --file="$brewfile" --formula --cask --tap 2>&1 || true)"
  if printf '%s\n' "$preview" | grep -q '^Error:'; then
    printf '%s\n' "$preview" | grep '^Error:' >&2
    # Without a preview, still ask before a cleanup that may remove packages.
    removals="  (could not preview; see the error above)"
  else
    removals="$(printf '%s\n' "$preview" | awk '
      /^Would uninstall casks:/ { section = "Casks"; next }
      /^Would uninstall formulae:/ { section = "Formulae"; next }
      /^Would untap:/ { section = "Taps"; next }
      /^Would|^Run / { section = "" }
      section != "" && NF { items[section] = items[section] " " $0 }
      END { for (s in items) printf "  %s:%s\n", s, items[s] }')"
  fi
fi
if [ -n "$removals" ]; then
  echo
  echo "Homebrew will remove these undeclared packages:"
  printf '%s\n' "$removals"
fi

if [ "${DOTFILES_DIFF_ONLY:-}" = 1 ]; then
  exit 0
fi

if [ -n "$removals" ] && [ "${DOTFILES_YES:-}" != 1 ]; then
  if [ ! -t 0 ]; then
    echo "Refusing to remove Homebrew packages without a terminal; set DOTFILES_YES=1."
    exit 1
  fi
  read -r -p "Continue and remove them? Declare any you want to keep first. [y/N] " answer
  case "$answer" in
    y | Y | yes) ;;
    *) echo "Nothing applied."; exit 1 ;;
  esac
fi

bash "$dotfiles_dir/setup/adopt-etc.sh"
bash "$dotfiles_dir/setup/migrate-agents.sh"

echo
echo "Applying (sudo)..."
sudo -H "$(dirname "$nix_bin")/nix-env" -p /nix/var/nix/profiles/system --set "$system"
sudo -H "$system/activate"

if $first_run; then
  # Agent CLIs that manage themselves install as the normal user. A network
  # failure here must not undo a completed system setup.
  bash "$dotfiles_dir/setup/agents.sh" ||
    echo "Agent setup did not finish; rerun it later with 'make agents'."
  echo "Setup complete. Reopen your terminal; run 'make' after future changes."
fi
