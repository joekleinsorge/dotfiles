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
      dotfilesConfig = rec {
        system = "aarch64-darwin";
        username = "joe";
        hostname = "joe";
        dotfilesPath = "/Users/${username}/git/dotfiles";
      };
      inherit (dotfilesConfig) system username hostname dotfilesPath;
      mkDarwin = extraModules: darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username system; };
        modules = [
          ./nix/darwin.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "pre-nix";
            home-manager.extraSpecialArgs = { inherit dotfilesPath; };
            home-manager.users.${username} = import ./nix/home.nix;
          }
        ] ++ extraModules;
      };
    in {
      lib.dotfilesConfig = dotfilesConfig;

      darwinConfigurations = {
        ${hostname} = mkDarwin [ ];
        "${hostname}-bootstrap" = mkDarwin [
          { nix-homebrew.autoMigrate = true; }
        ];
      };
    };
}
