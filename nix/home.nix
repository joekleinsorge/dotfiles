{ config, pkgs, dotfilesPath, ... }:

let
  liveLink = relativePath:
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${relativePath}";
  agentGuidance = ''
    # Global agent guidance

    - Preserve unrelated user changes and never discard work to simplify a task.
    - Keep credentials, tokens, private keys, generated logs, caches, and session state out of version control.
    - Prefer small, reversible changes and validate behavior before reporting completion.
    - Ask before applying system configuration, publishing changes, or taking destructive actions outside the requested scope.
    - Do not add agent attribution or co-author lines to commits.
  '';
in {
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    fd
    ghostty-bin
    python3Packages.virtualenv
    sqlite
    unzip
    zip
  ];

  home.file = {
    ".zshrc".source = liveLink "terminal/zsh/.zshrc";
    ".tmux.conf".source = liveLink "terminal/tmux/.tmux.conf";
    ".config/nvim".source = liveLink "terminal/nvim";
    ".config/starship.toml".source = liveLink "terminal/starship/starship.toml";
    ".config/ghostty/config".source = liveLink "terminal/ghostty/config";
    ".config/aerospace/aerospace.toml".source = liveLink "mac/.aerospace.toml";

    # Keep the K9s destination writable for logs and other runtime state while
    # linking each authored file from the repository.
    "Library/Application Support/k9s/config.yaml".source = ../terminal/k9s/config.yaml;
    "Library/Application Support/k9s/aliases.yaml".source = ../terminal/k9s/aliases.yaml;
    "Library/Application Support/k9s/plugins.yaml".source = ../terminal/k9s/plugins.yaml;
    "Library/Application Support/k9s/skins" = {
      source = ../terminal/k9s/skins;
      recursive = true;
    };

    ".codex/AGENTS.md".text = agentGuidance;
    ".claude/CLAUDE.md".text = agentGuidance;
    ".config/opencode/AGENTS.md".text = agentGuidance;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    KUBE_EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  # Marketplace downloads run explicitly via make vscode after the app exists.
}
