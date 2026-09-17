local M = {
	"folke/todo-comments.nvim",
	cmd = { "TodoTrouble", "TodoTelescope", "TodoQuickFix", "TodoLocList" },
	event = { "BufReadPost", "BufNewFile" },
	dependencies = "nvim-lua/plenary.nvim",
	keys = {
		{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search TODOs" },
		{ "<leader>xT", "<cmd>TodoTrouble<cr>", desc = "TODO diagnostics" },
	},
	opts = {
		colors = {
			info = { "DiagnosticInfo", "#FF8C00" },
		},
	},
}
return M
