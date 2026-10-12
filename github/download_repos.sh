#!/bin/bash
# Clones or updates every non-archived repository of the signed-in GitHub
# account into ~/git and installs pre-commit hooks where configured.
# Assumes gh is installed and `gh auth login` has been run.

mkdir -p ~/git
cd ~/git || exit 1

# gh lists only 30 repositories unless a limit is given.
gh repo list --no-archived --limit 1000 --json name --jq '.[].name' | while read -r repo; do
  if [ -d "$repo" ]; then
    echo "Pulling latest changes for $repo"
    git -C "$repo" pull --ff-only || echo "Could not update $repo; skipping."
  else
    echo "Cloning $repo"
    gh repo clone "$repo" || { echo "Could not clone $repo; skipping."; continue; }
  fi
  if [ -f "$repo/.pre-commit-config.yaml" ]; then
    echo "Installing pre-commit hooks for $repo"
    (cd "$repo" && pre-commit install)
  fi
done
