# Home Mac only. Nothing here reaches the work laptop. Shared configuration
# lives in nix/darwin.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    freetube
    icloudpd
    input-leap # Maintained fork of Barrier
    openscad
    wireguard-tools
    yt-dlp
  ];

  homebrew = {
    taps = [
      { name = "konstructio/taps"; trusted = true; }
      { name = "railwaycat/emacsmacport"; trusted = true; }
    ];
    brews = [
      "cask"
      "railwaycat/emacsmacport/emacs-mac@29"
      "handbrake"
      "konstructio/taps/kubefirst"
      "neofetch"
      "spotify-tui"
      "tailscale"
    ];
    casks = [
      "anki"
      "calibre"
      "docker-desktop" # Needs a paid license at larger companies
      "firefox"
      "handbrake-app"
      "losslesscut"
      "moonlight"
      "orion"
      "rectangle"
      "seafile-client"
      "vlc"
    ];
  };

  # Keep Homebrew exactly in sync with the lists above and in darwin.nix:
  # anything installed ad hoc with `brew install` is removed on the next
  # rebuild. Declare it here to keep it.
  dotfiles.homebrewCleanup = true;

  system.defaults = {
    # Skip the "downloaded from the internet" prompt. Not applied to the work
    # profile, where Gatekeeper quarantine is likely required by policy.
    LaunchServices.LSQuarantine = false;
    CustomSystemPreferences = {
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        ScheduleFrequency = 1;
        AutomaticDownload = 1;
        CriticalUpdateInstall = 1;
      };
      "com.apple.commerce".AutoUpdate = true;
    };
  };
}
