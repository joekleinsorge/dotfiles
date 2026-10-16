{ config, lib, pkgs, dotfilesPath, ... }:

let
  keyboardMappings = pkgs.writeShellScript "keyboard-mappings" ''
    set -euo pipefail

    # Caps Lock becomes the otherwise unused F18 on both keyboards (voice only).
    /usr/bin/hidutil property --set '{"UserKeyMapping":[
      {"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771181}
    ]}' >/dev/null

    # Windows keyboard: the key beside Space is Command, the next key is Option.
    # Include Caps Lock because a device-specific map replaces the global map.
    /usr/bin/hidutil property --matching '{"VendorID":12815,"ProductID":20616}' --set '{"UserKeyMapping":[
      {"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771181},
      {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771299},
      {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},
      {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771303},
      {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
    ]}' >/dev/null
  '';

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

  # AeroSpace rejects startup if both supported config paths exist. Preserve
  # the legacy home config outside its search paths before linking the XDG one.
  home.activation.migrateAeroSpaceConfig = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    legacy="$HOME/.aerospace.toml"
    if [ -e "$legacy" ] || [ -L "$legacy" ]; then
      backupRoot="$HOME/.local/state/dotfiles/backups"
      run mkdir -p "$backupRoot"
      if [ -z "''${DRY_RUN:-}" ]; then
        backupDir="$(/usr/bin/mktemp -d "$backupRoot/aerospace.XXXXXX")"
        run mv "$legacy" "$backupDir/aerospace.toml"
      else
        echo "Would preserve $legacy under $backupRoot/aerospace.*"
      fi
    fi
  '';

  # Remove legacy macOS remaps; hidutil below owns the physical layout.
  home.activation.externalKeyboardModifiers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults -currentHost write NSGlobalDomain \
      com.apple.keyboard.modifiermapping.12815-20616-0 -array
    run /usr/bin/defaults -currentHost write NSGlobalDomain \
      com.apple.keyboard.modifiermapping.0-0-0 -array
    run "${keyboardMappings}"
  '';

  # Apply at login without resetting keys during a held voice recording.
  launchd.agents.keyboard-mappings = {
    enable = true;
    config = {
      ProgramArguments = [ "${keyboardMappings}" ];
      RunAtLoad = true;
    };
  };

  # Keep the global hold-to-talk shortcut available after login.
  launchd.agents.opensuperwhisper = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" "-g" "-a" "/Applications/OpenSuperWhisper.app" ];
      RunAtLoad = true;
    };
  };

  # Marketplace downloads run explicitly via make vscode after the app exists.
}
