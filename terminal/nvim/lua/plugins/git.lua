return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame_opts = {
				delay = 300,
			},
		},
		keys = {
			{
				"<leader>gb",
				function()
					require("gitsigns").toggle_current_line_blame()
				end,
				desc = "Git Blame Toggle",
			},
			{
				"<leader>gp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Git Preview Hunk",
			},
		},
	},
}
