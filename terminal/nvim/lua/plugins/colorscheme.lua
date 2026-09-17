local M = {
	"rebelot/kanagawa.nvim",
	config = function()
		require("kanagawa").load("dragon")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	end,
}
return M
