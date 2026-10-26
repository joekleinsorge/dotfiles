{ config, pkgs, lib, inputs, username, system, ... }:

{
  imports = [ ./modules/homebrew-cleanup.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "terraform" ];

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # Command line tools for every Mac. Nix is the source of truth for these;
  # .zshrc puts Homebrew last on PATH so nothing shadows them.
  environment.systemPackages = with pkgs; [
    # Shell and files
    bat
    coreutils
    duf
    eza
    fzf
    gnused
    gping
    htop
    jq
    lynx
    ripgrep
    starship
    superfile
    tmux
    tree
    wget
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Editors, notes, and docs
    glow
    markdownlint-cli
    neovim
    proselint
    tree-sitter
    zk

    # Languages and build tools
    cargo
    go
    golangci-lint
    lua
    luaPackages.luacheck
    luarocks
    nodejs
    pipx
    python3
    ruff
    rustc
    shellcheck
    stylua
    yarn

    # Git and release
    gh
    git
    pre-commit

    # Containers, Kubernetes, and infrastructure
    ansible
    argocd
    azure-cli
    dive
    docker-client
    docker-compose
    grype
    k9s
    kubecolor
    kubectl
    kubectx
    kubernetes-helm
    terraform

    # Security and secrets
    age
    mkcert
    sops
  ];

  # .zshrc sources these plugins from the system profile.
  environment.pathsToLink = [ "/share/zsh-autosuggestions" "/share/zsh-syntax-highlighting" ];

  programs.zsh = {
    enable = true;
    # .zshrc runs compinit once with a daily cache and starship draws the
    # prompt, so the system zshrc must not repeat either on every shell.
    enableCompletion = false;
    enableBashCompletion = false;
    promptInit = "";
  };

  # Touch ID for sudo, including inside tmux sessions.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Keep the store from growing without bound across rebuilds.
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 12; Minute = 0; };
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # Preferences that suit any Mac. They apply on every rebuild; some take
  # effect after logging out. Sandboxed apps (Safari, Mail) cannot be written
  # here and stay in mac/set_defaults.sh, run with `make preferences`.
  system.defaults = {
    NSGlobalDomain = {
      NSDocumentSaveNewDocumentsToCloud = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.swipescrolldirection" = false;
      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
    finder.FXEnableExtensionChangeWarning = false;
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      expose-animation-duration = 0.1;
      launchanim = false;
      mru-spaces = false;
      show-recents = false;
    };
    CustomUserPreferences = {
      "fr.my-monkey.opensuperwhisper" =
        builtins.fromJSON (builtins.readFile ../mac/opensuperwhisper.json);
      NSGlobalDomain.WebKitDeveloperExtras = true;
      "com.apple.finder".WarnOnEmptyTrash = false;
      "com.apple.driver.AppleBluetoothMultitouch.trackpad".TrackpadCornerSecondaryClick = 2;
      "com.apple.BluetoothAudioAgent"."Apple Bitpool Min (editable)" = 40;
    };
  };

  # nix-homebrew owns the Homebrew installation. autoMigrate adopts an
  # existing Homebrew on the first run (keeping installed packages) and does
  # nothing once nix-homebrew manages it.
  nix-homebrew = {
    enable = true;
    user = username;
    autoMigrate = true;
    # Each activation syncs these taps from flake.lock. Taps stay mutable, so
    # other taps (such as ones a company installs) are left alone.
    taps = {
      "nikitabobko/homebrew-tap" = inputs.tap-nikitabobko;
      "my-monkeys/homebrew-tap" = inputs.tap-my-monkeys;
    };
  };

  # GUI applications and formulas without a stable nixpkgs equivalent remain
  # declarative here. Casks from third-party taps use their full name so a new
  # Mac can install them. Profile-specific entries live in nix/profiles.
  homebrew = {
    enable = true;
    taps = [
      { name = "nikitabobko/tap"; trusted = true; }
      { name = "my-monkeys/tap"; trusted = true; }
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "arc"
      # Agent CLIs ship faster than nixpkgs; Homebrew casks track releases.
      "claude-code"
      "codex"
      "dbeaver-community"
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-hack"
      "font-jetbrains-mono-nerd-font"
      "google-chrome"
      "kap"
      "my-monkeys/tap/opensuperwhisper"
      "postman"
      "shortcat"
      "spotify"
      "visual-studio-code"
      # Nightly includes the macOS Dictation fix missing from the 2024 stable build.
      "wezterm@nightly"
      "zoom"
    ];
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # nix-darwin's cleanup would also uninstall VS Code extensions and
      # npm, cargo, go, and uv packages missing from the Brewfile. Profiles
      # that want cleanup use dotfiles.homebrewCleanup instead.
      cleanup = "none";
    };
  };

  # Keep the remaining imperative macOS preferences available as an explicit,
  # reversible step. They affect the interactive user session and should not
  # run as root during every system activation.
  environment.etc."${username}-dotfiles/mac-set-defaults.sh".source = ../mac/set_defaults.sh;

  system.stateVersion = 6;
}
