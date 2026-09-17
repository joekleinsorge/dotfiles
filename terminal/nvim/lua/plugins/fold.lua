local M = {
	"kevinhwang91/nvim-ufo",
	event = { "BufReadPost", "BufNewFile" },
	enabled = true,
	dependencies = {
		"kevinhwang91/promise-async",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{
			"zO",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "Open all folds",
		},
		{
			"zC",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "Close all folds",
		},
	},
	config = function()
		vim.o.foldcolumn = "0"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		require("ufo").setup({
			provider_selector = function(_, filetype)
				if filetype == "markdown" then
					return ""
				end

				return { "treesitter", "indent" }
			end,
		})
	end,
}

return M
