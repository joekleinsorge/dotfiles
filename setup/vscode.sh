#!/usr/bin/env bash
set -euo pipefail
dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ ! -x "$code_bin" ]; then
  code_bin="$(command -v code || true)"
fi
if [ -z "$code_bin" ] || [ ! -x "$code_bin" ]; then
  echo "Install Visual Studio Code first by completing the macOS bootstrap."
  exit 1
fi
failed=0
while IFS= read -r extension || [ -n "$extension" ]; do
  case "$extension" in ''|'#'*) continue ;; esac
  if ! "$code_bin" --install-extension "$extension"; then
    echo "Could not install $extension; retry make vscode after checking Marketplace availability."
    failed=1
  fi
done < "$dotfiles_dir/nix/vscode-extensions.txt"
exit "$failed"
