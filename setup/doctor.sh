#!/usr/bin/env bash
# Read-only health check for an activated Mac. Reports configuration drift,
# such as a Home Manager link replaced by a copy, without changing anything.
# Run 'make' to repair what it finds.

set -uo pipefail

problems=0
ok() { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; problems=$((problems + 1)); }

echo "System"
if [ -x /run/current-system/sw/bin/darwin-rebuild ]; then
  ok "nix-darwin is active"
else
  bad "nix-darwin is not active; run 'make bootstrap'"
fi
if nix store info >/dev/null 2>&1 || nix store ping >/dev/null 2>&1; then
  ok "nix daemon responds"
else
  bad "nix daemon does not respond; reopen the terminal or restart the Mac"
fi
for shell_file in /etc/bashrc /etc/zshrc /etc/zprofile /etc/zshenv; do
  if [ -L "$shell_file" ]; then
    ok "$shell_file is managed"
  elif [ -e "$shell_file" ]; then
    bad "$shell_file was replaced, likely by a macOS update; run 'make'"
  fi
done
profile_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile"
if [ -f "$profile_file" ]; then
  ok "profile: $(cat "$profile_file")"
else
  bad "no profile recorded in $profile_file; run 'make'"
fi

echo "Home Manager links"
generation="$HOME/.local/state/home-manager/gcroots/current-home"
if [ -e "$generation/home-files" ]; then
  home_files="$(readlink "$generation/home-files")"
  drifted=0
  while IFS= read -r link; do
    relative="${link#"$home_files"/}"
    if [ "$(readlink "$HOME/$relative" 2>/dev/null)" != "$home_files/$relative" ]; then
      bad "$HOME/$relative is not the managed link"
      drifted=$((drifted + 1))
    fi
  done < <(find "$home_files" -type l)
  [ "$drifted" = 0 ] && ok "every managed file is linked"
else
  bad "no Home Manager generation found; run 'make'"
fi

echo "Applications"
if [ -e /Applications/Ghostty.app ]; then
  ok "Ghostty.app is in /Applications"
else
  bad "/Applications/Ghostty.app is missing; run 'make'"
fi
for tool in claude codex pi; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool is installed"
  else
    bad "$tool is missing; run 'make' then 'make agents'"
  fi
done

if [ "$problems" -gt 0 ]; then
  echo "$problems problem(s) found."
  exit 1
fi
echo "Everything looks healthy."
