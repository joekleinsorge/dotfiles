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
    # WezTerm loads color schemes from the themes directory beside its config.
    ".config/wezterm/wezterm.lua".source = liveLink "terminal/wezterm/.wezterm.lua";
    ".config/wezterm/themes".source = liveLink "terminal/wezterm/themes";
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

  # System Settings stores modifier mappings in the user's ByHost domain.
  # Scope the Alt/Windows swap to Wireless Gaming Keyboard (USB 320f:5088),
  # preserving the built-in keyboard and unrelated device preferences.
  home.activation.externalKeyboardModifiers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults -currentHost write NSGlobalDomain \
      com.apple.keyboard.modifiermapping.12815-20616-0 -array \
      '{ HIDKeyboardModifierMappingSrc = 30064771298; HIDKeyboardModifierMappingDst = 30064771299; }' \
      '{ HIDKeyboardModifierMappingSrc = 30064771299; HIDKeyboardModifierMappingDst = 30064771298; }' \
      '{ HIDKeyboardModifierMappingSrc = 30064771302; HIDKeyboardModifierMappingDst = 30064771303; }' \
      '{ HIDKeyboardModifierMappingSrc = 30064771303; HIDKeyboardModifierMappingDst = 30064771302; }'
  '';

  # Marketplace downloads run explicitly via make vscode after the app exists.
}
