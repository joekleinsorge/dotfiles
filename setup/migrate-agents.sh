#!/usr/bin/env bash
# Agents load every skill directory they find, so a Home Manager `.pre-nix`
# backup left beside a skill would load as a duplicate. Before activation,
# move earlier copies of the repository's skills out of every scanned
# directory into a timestamped backup instead.

set -euo pipefail

dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/$(date +%Y%m%d%H%M%S)"
skill_dirs=(
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.pi/agent/skills"
)

for skill in "$dotfiles_dir"/agents/skills/*/; do
  name="$(basename "$skill")"
  for skill_dir in "${skill_dirs[@]}"; do
    target="$skill_dir/$name"
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
      continue
    fi
    # Links that Home Manager already manages are left for it to update.
    case "$(readlink "$target" 2>/dev/null || true)" in
      /nix/store/*) continue ;;
    esac
    backup="$backup_root/${target#"$HOME"/}"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    echo "Moved $target to $backup"
  done
done
