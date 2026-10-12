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

Shared configuration lives in `nix/darwin.nix` and `nix/home.nix`; everything
there reaches both Macs. Home-only apps and tools (media, games, Docker
Desktop, Emacs, Tailscale, and similar) live in `nix/profiles/personal.nix` and
never reach the work laptop. Work-only additions go in `nix/profiles/work.nix`.
This repository is public, so keep employer names and endpoints out of it.

On the personal profile, Homebrew is kept exactly in sync with the
configuration: a formula, cask, or tap that isn't declared is removed on the
next `make`, so declare anything you install with `brew install`. The cleanup
is limited to formulae, casks, and taps; VS Code extensions and npm, cargo, go,
and uv packages are never touched. The work profile never removes Homebrew
packages, so anything the company installs with Homebrew is safe.

Use your normal account; the scripts ask for sudo only when needed, and Touch
ID works for sudo after the first activation. Terminal files link to the
checkout, so if you move it, run `make` again from the new location.

`make` builds the configuration as your normal user first, so a broken change
never needs sudo, then shows the package changes and any Homebrew packages that
would be removed, and asks before removing them. Only then does it apply the
configuration with sudo. The first run and later rebuilds use the same path.
`make diff` shows the same preview without applying anything.

Before applying, `make` moves aside shell files that block activation. Existing `/etc` shell files (`bashrc`, `zshrc`, `zprofile`,
`zshenv`) are preserved as `.before-nix-darwin`, with a timestamp suffix if that
backup already exists. Every rebuild repeats this step because macOS updates
restore those files and would otherwise block activation. Home Manager
preserves conflicting home files as `.pre-nix`. If a `.pre-nix` backup already
exists, review it before retrying instead of deleting it blindly.

Home Manager owns the links to `~/.zshrc`, `~/.config/nvim`, and the other
terminal configs. Don't replace them by hand with `ln -s` or copies; if they
drift, `make` restores them.
`make doctor` reports drift without changing anything: replaced links, `/etc`
files restored by macOS updates, Homebrew shadowing Nix tools, a missing
WezTerm app, or missing agent CLIs.

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

Command line tools come from Nix, and `.zshrc` puts Homebrew last on `PATH` so
it only supplies what Nix doesn't. macOS uses Nix Python and Node;
project-specific versions belong in project environments, and nvm still loads
on first use for projects that pin Node.

Most macOS preferences (typing, trackpad, Finder, Dock) are declared in
`system.defaults` and applied by every rebuild; some take effect after logging
out. The personal profile also turns off the downloaded-app quarantine prompt
and enables automatic updates; the work profile leaves both to IT.

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
declarative.

WezTerm is the terminal on every platform, from one configuration in
`terminal/wezterm`. On macOS it is a Homebrew cask, and Home Manager links the
config and its themes into `~/.config/wezterm`, so edits apply on the next
reload without a rebuild. It uses the Pnevma palette, bold 16-point JetBrains
Mono, 90% background opacity that dims when the window loses focus, and zero
padding. AeroSpace opens a new WezTerm window with Alt-Enter.

### External Windows keyboard on macOS

Home Manager declares the modifier swap in `nix/home.nix` for the Wireless
Gaming Keyboard (USB vendor `0x320f`, product `0x5088`). Both left and right
Alt keys act as Command; Windows keys act as Option. This matches the Mac
keyboard's physical modifier positions. The built-in keyboard is unchanged.

Use **Alt+C / Alt+V** on the external keyboard and **Command+C / Command+V**
on the Mac keyboard to copy/paste, including in WezTerm. **Ctrl+C** still
interrupts terminal commands. Shortcuts described as Option (including the
AeroSpace launcher above) use the Windows key on this external keyboard.

Run `make` to restore the mapping on either Nix profile. The activation writes
the user's host-specific macOS modifier preference; log out and back in if
macOS has not picked it up. To use another keyboard model, obtain its vendor
and product IDs with `hidutil list` and update the decimal IDs in the preference
key. To undo the swap, remove the activation block and restore this keyboard's
defaults in System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys.

### Rebuilding and validation

The flake defines `personal` and `work` configurations. The machine's account, checkout path, and architecture
come from `DOTFILES_*` environment variables that the scripts set, so they
evaluate with `--impure`. Pure evaluation falls back to `joe` on Apple Silicon.

On the first run, `nix-homebrew` installs Homebrew, or adopts an existing
installation while keeping its packages. For later changes, edit files in this
repository and run `make` again.

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
It also checks the WezTerm configuration's Lua syntax.
K9s cluster sessions are ignored by Git and kept local; shared settings and
themes remain tracked.

`make preferences` applies what `system.defaults` cannot: the startup chime,
Notification Center, and the sandboxed Safari and Mail settings. Grant your
terminal Full Disk Access first. A normal rebuild does not run it.

GitHub Actions runs the flake, profile, and script checks on every push and
pull request. Every Monday it opens a pull request that updates `flake.lock`
and checks the result; merge it, then run `make` on each Mac.

If you use `make` from Git Bash/MSYS, `make` auto-detects Windows and runs the same script.
