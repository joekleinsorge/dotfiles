{ config, lib, pkgs, dotfilesPath, ... }:

let
  liveLink = relativePath:
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${relativePath}";

  # One guidance file and one skills directory serve every agent. Codex and pi
  # both read ~/.agents/skills; Claude Code reads only ~/.claude/skills. Each
  # skill is linked individually so tools keep their own writable skill
  # directories for built-in and synced skills.
  agentGuidance = liveLink "agents/AGENTS.md";
  skillNames = builtins.attrNames
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../agents/skills));
  skillLinks = destination: lib.listToAttrs (map
    (name: lib.nameValuePair "${destination}/${name}" {
      source = liveLink "agents/skills/${name}";
    })
    skillNames);
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

    ".codex/AGENTS.md".source = agentGuidance;
    ".claude/CLAUDE.md".source = agentGuidance;
    ".config/opencode/AGENTS.md".source = agentGuidance;
    ".pi/agent/AGENTS.md".source = agentGuidance;
  } // skillLinks ".agents/skills" // skillLinks ".claude/skills";

  home.sessionVariables = {
    EDITOR = "nvim";
    KUBE_EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  # Marketplace downloads run explicitly via make vscode after the app exists.
}
