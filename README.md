# My dotfiles 

Works on macOS and Windows.

## macOS setup

On a new Mac, run this from your normal account:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/joekleinsorge/dotfiles/main/setup/install.sh)"
```

It installs Apple's command line tools and Nix (the official multi-user
installer) when they are missing, clones this repository to `~/git/dotfiles`,
and runs `make`, which bootstraps nix-darwin. Set `DOTFILES_DIR` to clone
elsewhere. Every step is skipped when already done. On a Mac that already has
the checkout, run `make` from it instead.

Nothing in the repository needs editing per machine. The scripts detect the
account, checkout path, and architecture, and pass them to the flake. They also
pick a profile:

- `work` on a Mac enrolled in device management (MDM), otherwise `personal`.
- The choice is remembered in `~/.config/dotfiles/profile`.
- Override it with `DOTFILES_PROFILE=work make` (or `personal`).

Shared configuration lives in `nix/darwin.nix` and `nix/home.nix`. Profile-only
packages and apps live in `nix/profiles/personal.nix` and
`nix/profiles/work.nix`. This repository is public, so keep employer names and
endpoints out of the work profile.

Use your normal account; the scripts ask for sudo only when needed, and Touch
ID works for sudo after the first activation. Terminal files link to the
checkout, so if you move it, run `make` again from the new location.

The bootstrap validates the machine and builds the system before moving shell
configuration files. Existing `/etc` shell files (`bashrc`, `zshrc`, `zprofile`,
`zshenv`) are preserved as `.before-nix-darwin`, with a timestamp suffix if that
backup already exists. Every rebuild repeats this step because macOS updates
restore those files and would otherwise block activation. Home Manager
preserves conflicting home files as `.pre-nix`. If a `.pre-nix` backup already
exists, review it before retrying instead of deleting it blindly.

Home Manager owns the links to `~/.zshrc`, `~/.config/nvim`, and the other
terminal configs. Don't replace them by hand with `ln -s` or copies; if they
drift, `make` restores them.
`make doctor` reports drift without changing anything: replaced links, `/etc`
files restored by macOS updates, a missing Ghostty app, or missing agent CLIs.

### Coding agents

Claude Code and Codex are Homebrew casks. pi installs and updates itself, so
bootstrap runs its official installer; `make agents` repeats that if pi is
missing and restores the pi packages in `agents/pi-packages.txt` and the
Claude Code plugins in `agents/claude-plugins.txt`. It only installs what is
missing.

`agents/AGENTS.md` is the global guidance for Claude Code, Codex, pi, and
opencode. Skills live in `agents/skills/<name>/SKILL.md` and are linked into
`~/.claude/skills` (Claude Code) and `~/.agents/skills` (Codex and pi). Both
are live links, so edits apply without a rebuild. Adding a new skill directory
needs one `make`. Each tool's own settings, credentials, and built-in skills
stay local and untracked.

After activation, reopen your terminal and run `make vscode` to restore editor
extensions. Marketplace downloads are separate so a retired extension or network
failure cannot prevent the system setup from completing. Sign in to services
such as GitHub separately and grant macOS Accessibility permission to AeroSpace.

macOS uses Nix Python; project-specific Python versions belong in project
environments. Homebrew installs libraries such as OpenSSL and libssh2 when
needed as dependencies. Removing explicit entries does not uninstall existing
packages while cleanup is disabled.

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

WSL preserves existing files and directories in unique sibling
`.before-dotfiles.*` directories before linking. Repeating setup leaves correct
links alone; restore an old file from the backup directory's `original` entry.

## Nix on macOS

The Nix flake is now the macOS source of truth for CLI packages and links the
existing terminal configuration into your home directory. GUI applications are
declarative, and Ghostty is installed from Nix with an app link exposed under
`/Applications` for Finder and Launchpad.

Ghostty is the macOS terminal; WezTerm configuration remains for Windows/WSL.
Ghostty uses the Pnevma palette, bold 16-point JetBrains Mono Nerd Font,
90% background opacity, zero padding, and a compact native tab titlebar.
WezTerm's Lua focus-dependent color/opacity changes and tab-button controls
do not map directly to Ghostty. Existing WezTerm installations are not
automatically uninstalled because Homebrew cleanup is intentionally disabled.

The flake defines `personal` and `work` configurations, each with a one-time
`-bootstrap` variant. The machine's account, checkout path, and architecture
come from `DOTFILES_*` environment variables that the scripts set, so they
evaluate with `--impure`. Pure evaluation falls back to `joe` on Apple Silicon.

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
On macOS it also validates Ghostty's configuration with the installed Ghostty.
K9s cluster sessions are ignored by Git and kept local; shared settings and
themes remain tracked.

The macOS preference script is installed below `/etc` in a directory derived
from the configured username and is only run through `make preferences`; a
normal rebuild does not reapply those interactive-user settings.

If you use `make` from Git Bash/MSYS, `make` auto-detects Windows and runs the same script.
