return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
		{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
		{ "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP References" },
		{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
	},
	opts = {
		focus = true,
	},
}
