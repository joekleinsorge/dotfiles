#!/usr/bin/env bash
# Shared by the bootstrap and rebuild entry points, before any mutation.
# The caller supplies dotfiles_dir and consumes configured_host.
# shellcheck disable=SC2154,SC2034

if [ "$(uname -s)" != Darwin ] || [ "$(id -u)" = 0 ]; then
  echo "Run this from your normal macOS account, without sudo."
  exit 1
fi
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install Apple's command line tools with xcode-select --install, then retry."
  exit 1
fi
nix_bin="$(command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)"
if [ ! -x "$nix_bin" ]; then
  echo "Install Nix from https://nixos.org/download/ and reopen your terminal."
  exit 1
fi
if [ ! -f "$dotfiles_dir/flake.lock" ]; then
  echo "Restore the committed flake.lock before continuing."
  exit 1
fi
machine_config="$("$nix_bin" --extra-experimental-features 'nix-command flakes' \
  eval --no-update-lock-file --json "$dotfiles_dir#lib.dotfilesConfig")"
flake_value() {
  printf '%s' "$machine_config" | /usr/bin/plutil -extract "$1" raw -o - -
}
configured_user="$(flake_value username)"
configured_host="$(flake_value hostname)"
configured_path="$(flake_value dotfilesPath)"
configured_system="$(flake_value system)"
case "$(uname -m)" in
  arm64) actual_system=aarch64-darwin ;;
  x86_64) actual_system=x86_64-darwin ;;
  *) echo "Unsupported architecture."; exit 1 ;;
esac
if [ "$configured_user" != "$(id -un)" ] ||
   [ "$configured_path" != "$dotfiles_dir" ] ||
   [ "$configured_system" != "$actual_system" ]; then
  echo "Update dotfilesConfig in flake.nix to match this machine:"
  echo "  username = $(id -un)"
  echo "  dotfilesPath = $dotfiles_dir"
  echo "  system = $actual_system (use a native terminal, not Rosetta)"
  exit 1
fi
