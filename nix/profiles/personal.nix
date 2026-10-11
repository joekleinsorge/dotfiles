# Personal Mac only. Shared configuration lives in nix/darwin.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yt-dlp
  ];

  homebrew = {
    taps = [ "kubefirst/tools" ];
    brews = [
      "kubefirst"
      "neofetch"
    ];
    casks = [ "firefox" ];
  };
}
