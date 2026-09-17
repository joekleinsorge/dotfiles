local M = {
	"nvim-lualine/lualine.nvim",
}

function M.config()
	local sl_hl = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
	vim.api.nvim_set_hl(0, "Copilot", { fg = "#6CC644", bg = sl_hl.bg })
	local icons = require("icons")
	local diff = {
		"diff",
		colored = true,
		symbols = { added = icons.git.LineAdded, modified = icons.git.LineModified, removed = icons.git.LineRemoved }, -- Changes the symbols used by the diff.
	}

	local copilot = function()
		local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
		if #buf_clients == 0 then
			return "LSP Inactive"
		end

		local copilot_active = false

		for _, client in pairs(buf_clients) do
			if client.name == "copilot" then
				copilot_active = true
			end
		end

		if copilot_active then
			return "%#Copilot#" .. icons.git.Octoface .. "%*"
		end
		return ""
	end

	require("lualine").setup({
		options = {
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },

			ignore_focus = { "oil" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = { diff },
			lualine_x = { "diagnostics", copilot },
			lualine_y = { "filetype" },
			lualine_z = { "progress" },
		},
		extensions = { "quickfix", "man" },
	})
end

return M
