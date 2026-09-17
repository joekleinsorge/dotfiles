local function close_diffbandit()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local state = require("diffbandit.state")
	local host = state.sessions[tabpage] or state.panels[tabpage]

	if host and not host.disposed and type(host.close) == "function" then
		host:close()
		return
	end

	vim.notify("No DiffBandit view is open in this tab", vim.log.levels.INFO)
end

return {
	"CoreyKaylor/diffbandit.nvim",
	cmd = {
		"DiffBandit",
		"DiffBanditBuffers",
		"DiffBanditCommitPanel",
		"DiffBanditFolderDiff",
		"DiffBanditGit",
		"DiffBanditGitCheckout",
		"DiffBanditGitCommit",
		"DiffBanditGitCompare",
		"DiffBanditGitCurrent",
		"DiffBanditGitLog",
		"DiffBanditGitMenu",
		"DiffBanditMerge",
	},
	keys = {
		{ "<leader>gg", "<cmd>DiffBanditGit<cr>", desc = "Review changes" },
		{ "<leader>gd", "<cmd>DiffBanditGitCurrent<cr>", desc = "Review current file" },
		{ "<leader>gc", "<cmd>DiffBanditCommitPanel<cr>", desc = "Commit changes" },
		{ "<leader>gl", "<cmd>DiffBanditGitLog --all --max-count 50<cr>", desc = "Git log" },
		{ "<leader>gm", "<cmd>DiffBanditGitMenu<cr>", desc = "Git menu" },
		{ "<leader>gq", close_diffbandit, desc = "Close DiffBandit" },
	},
	opts = {},
	config = function(_, opts)
		require("diffbandit").setup(opts)

		vim.api.nvim_create_user_command("DiffBanditClose", close_diffbandit, {
			desc = "Close the DiffBandit view in the current tab",
		})

		local group = vim.api.nvim_create_augroup("user_diffbandit", { clear = true })
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			callback = function(event)
				vim.schedule(function()
					local ok, diffbandit = pcall(require, "diffbandit")
					if not ok or not vim.api.nvim_buf_is_valid(event.buf) or not diffbandit.owns_buffer(event.buf) then
						return
					end

					vim.keymap.set("n", "<Esc>", close_diffbandit, {
						buffer = event.buf,
						desc = "Close DiffBandit",
						nowait = true,
						silent = true,
					})
				end)
			end,
		})
	end,
}
