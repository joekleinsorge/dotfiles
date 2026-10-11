# Work laptop only. Shared configuration lives in nix/darwin.nix; home-only
# apps live in nix/profiles/personal.nix and never reach this profile.
# This repository is public: keep employer names and endpoints out of it.
#
# Homebrew cleanup stays off here so packages the company installs with
# Homebrew are never removed. Software updates are left to device management.
{ ... }:

{
}
