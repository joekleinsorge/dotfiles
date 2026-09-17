local M = {
	"RRethy/vim-illuminate",
	event = "VeryLazy",
}

function M.config()
	require("illuminate").configure({
		-- The Treesitter provider still uses nvim-treesitter's legacy locals
		-- API, which is incompatible with Neovim 0.12. LSP remains the most
		-- accurate provider and regex covers buffers without an LSP client.
		providers = { "lsp", "regex" },
		delay = 150,
		filetypes_denylist = {
			"alpha",
			"diffbandit",
			"lazy",
			"mason",
			"oil",
			"qf",
			"Trouble",
			"TelescopePrompt",
		},
	})
end

return M
