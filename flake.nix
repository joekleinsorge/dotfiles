{
  description = "Joe's macOS configuration and dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { darwin, home-manager, nix-homebrew, ... }:
    let
      # The setup scripts detect the machine and pass it through the
      # environment with --impure, so no Mac needs its own edit here. Pure
      # evaluation (flake check, CI) falls back to the defaults below.
      envOr = name: default:
        let value = builtins.getEnv name;
        in if value == "" then default else value;
      machine = rec {
        username = envOr "DOTFILES_USER" "joe";
        system = envOr "DOTFILES_SYSTEM" "aarch64-darwin";
        dotfilesPath = envOr "DOTFILES_PATH" "/Users/${username}/git/dotfiles";
      };
      inherit (machine) username system dotfilesPath;

      profiles = [ "personal" "work" ];

      mkDarwin = profile: darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username system profile; };
        modules = [
          ./nix/darwin.nix
          ./nix/profiles/${profile}.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "pre-nix";
            home-manager.extraSpecialArgs = { inherit dotfilesPath profile; };
            home-manager.users.${username} = import ./nix/home.nix;
          }
        ];
      };
    in {
      lib = { inherit machine profiles; };

      darwinConfigurations = builtins.listToAttrs
        (map (profile: { name = profile; value = mkDarwin profile; }) profiles);
    };
}
