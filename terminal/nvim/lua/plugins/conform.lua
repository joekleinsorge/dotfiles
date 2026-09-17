return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>lf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			desc = "Format Buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			bash = { "shfmt" },
			css = { "prettier" },
			html = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "jq" },
			jsonc = { "prettier" },
			lua = { "stylua" },
			markdown = { "prettier" },
			python = { "ruff_organize_imports", "ruff_format" },
			ruby = { "rubocop" },
			sh = { "shfmt" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			yaml = { "yamlfmt" },
		},
		format_on_save = function(bufnr)
			local disabled_filetypes = {
				markdown = true,
			}

			if disabled_filetypes[vim.bo[bufnr].filetype] then
				return
			end

			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
	},
}
