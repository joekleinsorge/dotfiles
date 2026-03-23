.POSIX:

.PHONY: default mac terminal github windows wsl


default:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		$(MAKE) windows; \
	elif [ -n "$$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then \
		$(MAKE) wsl; \
	else \
		$(MAKE) mac terminal github; \
	fi

mac: 
	sh ./mac/install.sh
	sh ./mac/set_defaults.sh

terminal:
	sh ./terminal/link.sh

github:
	sh ./github/download_repos.sh

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
