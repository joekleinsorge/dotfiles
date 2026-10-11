# Removes Homebrew formulae, casks, and taps that the configuration does not
# declare. nix-darwin's own homebrew.onActivation.cleanup also removes VS Code
# extensions and npm, cargo, go, uv, and krew packages missing from the
# Brewfile, so this limits `brew bundle cleanup` to the three Homebrew types.
{ config, lib, pkgs, username, ... }:

let
  brewfile = pkgs.writeText "Brewfile" config.homebrew.brewfile;
in {
  options.dotfiles.homebrewCleanup = lib.mkEnableOption
    "removing Homebrew formulae, casks, and taps this configuration does not declare";

  config = lib.mkIf config.dotfiles.homebrewCleanup {
    system.activationScripts.postActivation.text = lib.mkAfter ''
      echo "Removing Homebrew formulae, casks, and taps that are not declared..." >&2
      sudo --user=${username} --set-home \
        env PATH="${config.homebrew.prefix}/bin:$PATH" HOMEBREW_NO_AUTO_UPDATE=1 \
        brew bundle cleanup --file=${brewfile} --formula --cask --tap --force
    '';
  };
}
