# Dotfiles repository guidance

- Preserve support for macOS and Windows with WSL when changing shared terminal configuration.
- Treat `flake.nix`, `nix/darwin.nix`, and `nix/home.nix` as the macOS source of truth.
- Keep generated logs, credentials, caches, sessions, and other runtime state out of Git.
- Run `make check` after changing Nix, shell, Neovim, or bootstrap files.
- Do not apply the macOS configuration or operating-system defaults unless the user explicitly asks.
