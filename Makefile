.POSIX:

.PHONY: default bootstrap mac rebuild update preferences github check runtime-check nix-check shell-check nvim-check ghostty-check windows wsl vscode


default:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		$(MAKE) windows; \
	elif [ -n "$$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then \
		$(MAKE) wsl; \
	else \
		$(MAKE) mac; \
	fi

bootstrap:
	bash ./setup/mac.sh

mac: rebuild

rebuild:
	@if command -v darwin-rebuild >/dev/null 2>&1 || [ -x /run/current-system/sw/bin/darwin-rebuild ]; then \
		bash ./rebuild.sh; \
	elif command -v nix >/dev/null 2>&1 || [ -x /nix/var/nix/profiles/default/bin/nix ]; then \
		bash ./setup/mac.sh; \
	else \
		echo "Nix is not installed. Install it from https://nixos.org/download/ and run 'make bootstrap'."; \
		exit 1; \
	fi

update:
	@nix_bin="$$(command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)"; \
		"$$nix_bin" --extra-experimental-features 'nix-command flakes' flake update
	$(MAKE) check

vscode:
	bash ./setup/vscode.sh

preferences:
	sh ./mac/set_defaults.sh

github:
	sh ./github/download_repos.sh

nvim-check:
	@command -v stylua >/dev/null 2>&1 || { echo "stylua is required"; exit 1; }
	stylua --check terminal/nvim
	@for file in $$(rg --files terminal/nvim -g '*.lua'); do luac -p "$$file" || exit 1; done
	@tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/dotfiles-nvim-check.XXXXXX")"; \
		trap 'rm -rf "$$tmp"' 0 1 2 3 15; \
		real_data="$${XDG_DATA_HOME:-$$HOME/.local/share}/nvim"; \
		mkdir -p "$$tmp/data/nvim/site"; \
		XDG_DATA_HOME="$$tmp/data" XDG_STATE_HOME="$$tmp/state" XDG_CACHE_HOME="$$tmp/cache" \
		NVIM_SMOKE_TEST=1 NVIM_SMOKE_DATA_DIR="$$real_data" \
		nvim --headless -u "$(CURDIR)/terminal/nvim/init.lua" -i NONE \
		"+lua dofile('$(CURDIR)/terminal/nvim/scripts/smoke.lua')"

nix-check:
	@nix_bin="$$(command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)"; \
		"$$nix_bin" --extra-experimental-features "nix-command flakes" flake check --no-build
	@nix_bin="$$(command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)"; \
		host="$$($$nix_bin --extra-experimental-features 'nix-command flakes' eval --raw .#lib.dotfilesConfig.hostname)"; \
		"$$nix_bin" --extra-experimental-features "nix-command flakes" \
		build ".#darwinConfigurations.$$host.system" \
		".#darwinConfigurations.$$host-bootstrap.system" --dry-run

shell-check:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck is required"; exit 1; }
	shellcheck -x $$(rg --files -g '*.sh')
	zsh -n terminal/zsh/.zshrc
runtime-check:
	@if find . -path './.git' -prune -o -type f \
		\( -name '*.log' -o -name '.nvimlog' -o -name '*.pre-nix' \) -print | grep -q .; then \
		echo "Generated runtime or backup files are present in the repository."; \
		find . -path './.git' -prune -o -type f \
			\( -name '*.log' -o -name '.nvimlog' -o -name '*.pre-nix' \) -print; \
		exit 1; \
	fi
	@if find terminal/k9s -type l -print | grep -q .; then \
		echo "K9s source files must be regular files, not runtime symlinks."; \
		find terminal/k9s -type l -print; \
		exit 1; \
	fi

ghostty-check:
	@if [ "$$(uname -s)" = Darwin ]; then \
		ghostty_bin="$$(command -v ghostty 2>/dev/null || echo /Applications/Ghostty.app/Contents/MacOS/ghostty)"; \
		[ -x "$$ghostty_bin" ] || { echo "Install Ghostty before running ghostty-check."; exit 1; }; \
		"$$ghostty_bin" +validate-config --config-file="$(CURDIR)/terminal/ghostty/config"; \
	else \
		echo "Skipping macOS Ghostty validation on this platform."; \
	fi

check: runtime-check nix-check shell-check nvim-check ghostty-check

wsl:
	bash ./wsl/setup.sh

windows:
	@script_path="$$(pwd)/windows/setup.ps1"; \
	if command -v cygpath >/dev/null 2>&1; then \
		script_path="$$(cygpath -aw "$$script_path")"; \
	elif pwd -W >/dev/null 2>&1; then \
		script_path="$$(pwd -W)/windows/setup.ps1"; \
	fi; \
	if command -v pwsh >/dev/null 2>&1; then \
		pwsh -NoProfile -ExecutionPolicy Bypass -File "$$script_path"; \
	elif command -v powershell.exe >/dev/null 2>&1; then \
		powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$$script_path"; \
	else \
		echo "PowerShell not found. Run windows/setup.ps1 manually from PowerShell."; \
		exit 1; \
	fi
