local M = {
	"numToStr/Comment.nvim",
	keys = {
		{
			"<leader>/",
			function()
				require("Comment.api").toggle.linewise.current()
			end,
			mode = "n",
			desc = "Toggle comment",
		},
		{
			"<leader>/",
			'<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<cr>',
			mode = "x",
			desc = "Toggle comment",
		},
		{ "gcc", mode = "n", desc = "Comment line" },
		{ "gbc", mode = "n", desc = "Comment block" },
		{ "gc", mode = { "n", "x", "o" }, desc = "Comment" },
		{ "gb", mode = { "n", "x", "o" }, desc = "Comment block" },
		{ "gco", mode = "n", desc = "Comment below" },
		{ "gcO", mode = "n", desc = "Comment above" },
		{ "gcA", mode = "n", desc = "Comment end of line" },
	},
}

function M.config()
	require("Comment").setup({
		padding = true,
		sticky = true,
		toggler = {
			line = "gcc",
			block = "gbc",
		},
		opleader = {
			line = "gc",
			block = "gb",
		},
		extra = {
			above = "gcO",
			below = "gco",
			eol = "gcA",
		},
		mappings = {
			basic = true,
			extra = true,
		},
	})
end

return M
