# My dotfiles 

Works on macOS and Windows.

## macOS setup

Install Apple's command line tools and wait for the installer to finish:

```bash
xcode-select --install
```

Install Nix using the [official instructions](https://nixos.org/download/), then
reopen your terminal, and clone the repository:

```bash
mkdir -p ~/git
git clone https://github.com/JoeKleinsorge/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
```

Review `dotfilesConfig` in `flake.nix`: the defaults require the account `joe`,
Apple Silicon, and `/Users/joe/git/dotfiles`. Adjust these values for your Mac,
then run `make`. It automatically bootstraps when nix-darwin is absent.
Use your normal account; the script asks for sudo only when needed.
The checkout must stay at the configured path because terminal files link to it.

The bootstrap validates the machine and builds the system before moving shell
configuration files. Existing shell files are preserved as `.before-nix-darwin`;
Home Manager preserves conflicting home files as `.pre-nix`. If a backup already
exists, review it before retrying instead of deleting it blindly.

After activation, reopen your terminal and run `make vscode` to restore editor
extensions. Marketplace downloads are separate so a retired extension or network
failure cannot prevent the system setup from completing. Sign in to services
such as GitHub separately and grant macOS Accessibility permission to AeroSpace.

After the first activation, use `make` or `./rebuild.sh` to apply changes.
Repository downloads and macOS preference changes are intentionally separate:

```bash
make github
make preferences
```

## Windows setup

This repo uses a WSL-first setup on Windows.

From Windows PowerShell in this repo, run:

```powershell
./windows/setup.ps1
```

If you are already inside your Ubuntu WSL terminal in this repo, run:

```bash
make
```

or:

```bash
bash ./wsl/setup.sh
```

What it does:
- Installs WSL Ubuntu if needed.
- Runs the Linux setup inside your WSL distro.
- Installs WSL packages and links terminal configs in WSL home.
- Writes `%USERPROFILE%\\.wezterm.lua` so WezTerm can load the repo config from any checkout path.

## Nix on macOS

The Nix flake is now the macOS source of truth for CLI packages and links the
existing terminal configuration into your home directory. GUI applications are
declarative, and Ghostty is installed from Nix with an app link exposed under
`/Applications` for Finder and Launchpad.

Machine-specific values live together in `dotfilesConfig` in `flake.nix`.
Change the username, host label, architecture, and checkout path there before
the first activation if this is not Joe's Apple Silicon Mac.

The first activation performs safety checks, lets `nix-homebrew` install or
adopt Homebrew using a one-time bootstrap configuration, migrates the legacy
K9s directory symlink if present, and applies the locked flake. The bootstrap
launcher uses the exact nix-darwin revision recorded in `flake.lock`:

```bash
make bootstrap
```

For normal updates, edit files in this repository and run:

```bash
./rebuild.sh
```

Normal rebuilds consume `flake.lock` without changing it. Update dependencies
deliberately, followed by the complete validation suite, with:

```bash
make update
```

Frequently edited terminal and editor files are live-linked from the checkout,
so those edits do not need a rebuild. Package lists, Homebrew declarations,
Home Manager links, and system settings do need one.

Validate changes without applying them:

```bash
make check
```

Run this after bootstrap, when its validation tools are installed. It checks
the flake, performs a dry-run build, validates shell scripts, and
runs the Neovim formatting, syntax, and isolated headless smoke checks. It also
rejects generated logs and Home Manager backup files in the repository.

The macOS preference script is installed below `/etc` in a directory derived
from the configured username and is only run through `make preferences`; a
normal rebuild does not reapply those interactive-user settings.

If you use `make` from Git Bash/MSYS, `make` auto-detects Windows and runs the same script.
