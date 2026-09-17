#!/usr/bin/env bash

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
repository_config="$(cd "$dotfiles_dir/terminal/k9s" && pwd -P)"
runtime_config="$HOME/Library/Application Support/k9s"

if [ -L "$runtime_config" ]; then
  link_target="$(readlink "$runtime_config")"
  case "$link_target" in
    /*) resolved_target="$(cd "$link_target" && pwd -P)" ;;
    *) resolved_target="$(cd "$(dirname "$runtime_config")/$link_target" && pwd -P)" ;;
  esac

  if [ "$resolved_target" != "$repository_config" ]; then
    echo "Refusing to replace unrelated K9s symlink: $runtime_config -> $link_target"
    exit 1
  fi

  unlink "$runtime_config"
  mkdir -p "$runtime_config"
  /usr/bin/rsync -a \
    --exclude '*.log' \
    --exclude '*.pre-nix' \
    "$repository_config/" "$runtime_config/"
  echo "Migrated K9s from a repository symlink to a writable runtime directory."
elif [ -e "$runtime_config" ] && [ ! -d "$runtime_config" ]; then
  echo "Refusing to replace non-directory K9s path: $runtime_config"
  exit 1
else
  mkdir -p "$runtime_config"
fi
