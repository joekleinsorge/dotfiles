local function assert_ok(value, message)
	if not value then
		error(message, 2)
	end
end

local function plugin_url(plugin)
	return (plugin.url or ""):gsub("%.git$", "")
end

vim.defer_fn(function()
	local ok, err = xpcall(function()
		local plugins = require("lazy.core.config").plugins

		assert_ok(plugins["nvim-treesitter"], "nvim-treesitter is not configured")
		assert_ok(plugins["nvim-treesitter"].lazy == false, "nvim-treesitter must not be lazy-loaded")
		assert_ok(plugins["oil.nvim"], "oil.nvim is not configured")
		assert_ok(
			plugin_url(plugins["oil.nvim"]):find("stevearc/oil.nvim", 1, true),
			"oil.nvim is not using the requested repository"
		)
		assert_ok(plugins["diffbandit.nvim"], "diffbandit.nvim is not configured")
		assert_ok(
			plugin_url(plugins["diffbandit.nvim"]):find("CoreyKaylor/diffbandit.nvim", 1, true),
			"diffbandit.nvim is not using the requested repository"
		)
		for _, name in ipairs({ "cellular-automaton.nvim", "CopilotChat.nvim", "project.nvim", "undotree" }) do
			assert_ok(not plugins[name], name .. " should have been removed")
		end
		assert_ok(vim.g.loaded_python3_provider == 0, "the unused Python provider is enabled")
		assert_ok(vim.g.loaded_netrwPlugin == 1, "netrw is enabled alongside Oil")
		assert_ok(vim.bo.swapfile, "swap files are disabled")

		assert_ok(vim.fn.exists(":Oil") == 2, ":Oil is unavailable")
		assert_ok(vim.fn.exists(":DiffBanditGit") == 2, ":DiffBanditGit is unavailable")
		vim.cmd("Lazy! load telescope.nvim")
		assert_ok(pcall(require, "telescope"), "Telescope failed to load")
		vim.cmd("Lazy! load nvim-cmp")
		local cmp_ok, cmp = pcall(require, "cmp")
		assert_ok(cmp_ok, "nvim-cmp failed to load")
		local completion_sources = vim.tbl_map(function(source)
			return source.name
		end, cmp.get_config().sources)
		assert_ok(
			vim.deep_equal(completion_sources, { "lazydev", "nvim_lsp", "luasnip", "path", "buffer" }),
			"nvim-cmp has unexpected sources: " .. vim.inspect(completion_sources)
		)
		vim.cmd("Lazy! load nvim-lint")
		assert_ok(
			vim.tbl_isempty(vim.api.nvim_get_autocmds({ group = "user_lint", event = "InsertLeave" })),
			"linting still runs on InsertLeave"
		)
		vim.cmd("Lazy! load oil.nvim")
		assert_ok(pcall(require, "oil"), "Oil failed to load")
		vim.cmd("Lazy! load diffbandit.nvim")
		assert_ok(pcall(require, "diffbandit"), "DiffBandit failed to load")
		assert_ok(vim.fn.exists(":DiffBanditClose") == 2, ":DiffBanditClose is unavailable")
		local close_mapping = vim.fn.maparg("<leader>gq", "n", false, true)
		assert_ok(type(close_mapping) == "table" and close_mapping.callback, "the DiffBandit close keymap is missing")
		local diffbandit_state = require("diffbandit.state")
		local current_tab = vim.api.nvim_get_current_tabpage()
		local previous_session = diffbandit_state.sessions[current_tab]
		local close_called = false
		diffbandit_state.sessions[current_tab] = {
			close = function()
				close_called = true
			end,
		}
		close_mapping.callback()
		diffbandit_state.sessions[current_tab] = previous_session
		assert_ok(close_called, "the DiffBandit close keymap did not close the active view")
		local providers = require("illuminate.config").providers(0)
		assert_ok(vim.deep_equal(providers, { "lsp", "regex" }), "Illuminate has unsafe providers")

		vim.bo.filetype = "lua"
		assert_ok(pcall(vim.treesitter.start, 0, "lua"), "the Lua Treesitter parser failed to start")

		vim.cmd("silent checkhealth lazy nvim-treesitter vim.deprecated vim.lsp which-key")
		local health
		local health_complete = vim.wait(10000, function()
			health = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
			return health:find("lazy:", 1, true)
				and health:find("nvim-treesitter:", 1, true)
				and health:find("vim.deprecated:", 1, true)
				and health:find("vim.lsp:", 1, true)
				and health:find("which-key:", 1, true)
		end, 50)
		assert_ok(health_complete, "Neovim health checks timed out")
		assert_ok(not health:find("❌ ERROR", 1, true), "a Neovim health check failed:\n" .. health)
	end, debug.traceback)

	if not ok then
		vim.api.nvim_err_writeln(err)
		vim.cmd("cquit 1")
		return
	end

	print("Neovim smoke checks passed")
	vim.cmd("qa!")
end, 500)
