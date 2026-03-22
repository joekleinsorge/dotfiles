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

From PowerShell in this repo, run:

```powershell
./windows/setup.ps1
```

What it does:
- Installs WSL Ubuntu if needed.
- Runs the Linux setup inside your WSL distro.
- Installs WSL packages and links terminal configs in WSL home.

If you use `make` from Git Bash/MSYS, `make` auto-detects Windows and runs the same script.
