# My dotfiles 

Works on macOS and Windows.

## macOS setup

If not already done, run:

```bash
sudo softwareupdate -i -a
xcode-select --install
```

Then run:

``` bash
make
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

If you use `make` from Git Bash/MSYS, `make` auto-detects Windows and runs the same script.
