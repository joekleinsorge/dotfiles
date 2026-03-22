.POSIX:

.PHONY: default mac terminal github windows


default:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		$(MAKE) windows; \
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

windows:
	@if command -v pwsh >/dev/null 2>&1; then \
		pwsh -NoProfile -ExecutionPolicy Bypass -File ./windows/setup.ps1; \
	elif command -v powershell.exe >/dev/null 2>&1; then \
		powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./windows/setup.ps1; \
	else \
		echo "PowerShell not found. Run windows/setup.ps1 manually from PowerShell."; \
		exit 1; \
	fi
