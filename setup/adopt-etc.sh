#!/usr/bin/env bash
# nix-darwin owns these shell startup files. The Nix installer and macOS
# updates write regular files at these paths, which makes activation refuse to
# continue. Preserve each one beside the original instead of deleting it.

set -euo pipefail

if [ "$(uname -s)" != Darwin ]; then
  exit 0
fi

for shell_file in /etc/bashrc /etc/zshrc /etc/zprofile /etc/zshenv; do
  if [ ! -e "$shell_file" ] || [ -L "$shell_file" ]; then
    continue
  fi
  backup_file="${shell_file}.before-nix-darwin"
  if [ -e "$backup_file" ]; then
    backup_file="${backup_file}.$(date +%Y%m%d%H%M%S)"
  fi
  echo "Preserving $shell_file as $backup_file"
  sudo mv -n "$shell_file" "$backup_file"
done
