#!/usr/bin/env bash
# Shared by the bootstrap and rebuild entry points, before any mutation.
# The caller supplies dotfiles_dir. This detects the machine and exports:
#   nix_bin          path to the nix binary
#   flake_profile    personal or work; names the darwinConfiguration
#   dotfiles_env     DOTFILES_* assignments the flake reads with --impure
# shellcheck disable=SC2154,SC2034

if [ "$(uname -s)" != Darwin ] || [ "$(id -u)" = 0 ]; then
  echo "Run this from your normal macOS account, without sudo."
  exit 1
fi
if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = 1 ]; then
  echo "This shell runs under Rosetta. Use a native arm64 terminal."
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

case "$(uname -m)" in
  arm64) machine_system=aarch64-darwin ;;
  x86_64) machine_system=x86_64-darwin ;;
  *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

# The profile is chosen once per Mac and remembered outside the repository.
# DOTFILES_PROFILE overrides both the remembered and the detected value.
profile_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile"
flake_profile="${DOTFILES_PROFILE:-}"
if [ -z "$flake_profile" ] && [ -f "$profile_file" ]; then
  flake_profile="$(cat "$profile_file")"
fi
if [ -z "$flake_profile" ]; then
  # Company laptops are enrolled in device management; personal Macs are not.
  if /usr/bin/profiles status -type enrollment 2>/dev/null | grep -q 'MDM enrollment: Yes'; then
    flake_profile=work
  else
    flake_profile=personal
  fi
  echo "Detected the '$flake_profile' profile. Override with DOTFILES_PROFILE=personal or work."
fi
case "$flake_profile" in
  personal | work) ;;
  *) echo "Unknown profile '$flake_profile'; use personal or work."; exit 1 ;;
esac
mkdir -p "$(dirname "$profile_file")"
printf '%s\n' "$flake_profile" >"$profile_file"

dotfiles_env=(
  "DOTFILES_USER=$(id -un)"
  "DOTFILES_PATH=$dotfiles_dir"
  "DOTFILES_SYSTEM=$machine_system"
)
echo "Using profile '$flake_profile' for $(id -un) on $machine_system."
