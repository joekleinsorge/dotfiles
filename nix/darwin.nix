{ config, pkgs, lib, username, system, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "terraform" ];

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  environment.systemPackages = with pkgs; [
    argocd
    azure-cli
    bat
    coreutils
    duf
    eza
    fzf
    ffmpeg
    gh
    git
    gnused
    go
    kubernetes-helm
    htop
    jq
    k9s
    kubectl
    lua
    luaPackages.luacheck
    luarocks
    mkcert
    neovim
    nodejs
    pre-commit
    proselint
    python3
    ripgrep
    ruff
    shellcheck
    starship
    stylua
    terraform
    tmux
    tree
    wget
    yt-dlp
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  programs.zsh.enable = true;

  # nix-homebrew owns the Homebrew installation. The separate bootstrap
  # configuration enables autoMigrate for its one-time adoption only.
  nix-homebrew = {
    enable = true;
    user = username;
  };

  # GUI applications and formulas without a stable nixpkgs equivalent remain
  # declarative here. `darwin-rebuild switch` is the only command needed to
  # reconcile them.
  homebrew = {
    enable = true;
    taps = [
      "kubefirst/tools"
    ];
    brews = [
      "libssh2"
      "kubefirst"
      "neofetch"
      "openssl@3"
      "python@3.10"
      "python@3.11"
    ];
    casks = [
      "aerospace"
      "firefox"
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-hack"
      "font-jetbrains-mono-nerd-font"
      "visual-studio-code"
      # Ghostty is installed through nix/home.nix (ghostty-bin).
    ];
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };

  # Keep the existing macOS preferences available as an explicit, reversible
  # step. They affect the interactive user session and should not run as root
  # during every system activation.
  environment.etc."${username}-dotfiles/mac-set-defaults.sh".source = ../mac/set_defaults.sh;

  # Nix profiles contain the Ghostty.app bundle, but Finder does not search
  # profile application directories. Expose the immutable Nix app at the
  # conventional macOS location without copying it out of the store.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    ghostty_app="${pkgs.ghostty-bin}/Applications/Ghostty.app"
    if [ -d "$ghostty_app" ]; then
      if [ -L /Applications/Ghostty.app ]; then
        case "$(readlink /Applications/Ghostty.app)" in
          /nix/store/*/Applications/Ghostty.app)
            ln -sfn "$ghostty_app" /Applications/Ghostty.app ;;
          *) echo "Preserving existing Ghostty symlink." ;;
        esac
      elif [ ! -e /Applications/Ghostty.app ]; then
        ln -s "$ghostty_app" /Applications/Ghostty.app
      fi
      mkdir -p "/Applications/Nix Apps"
      ln -sfn "$ghostty_app" "/Applications/Nix Apps/Ghostty.app"
    fi
  '';

  system.stateVersion = 6;
}
