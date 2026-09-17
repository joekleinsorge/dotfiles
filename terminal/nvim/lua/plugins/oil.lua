return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		{ "<leader>e", "<cmd>Oil<cr>", desc = "Explorer" },
	},
	opts = {
		default_file_explorer = true,
		columns = { "icon" },
		keymaps = {
			q = "actions.close",
		},
		view_options = {
			show_hidden = true,
		},
	},
}
