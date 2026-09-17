local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "qf", "help", "man", "lspinfo" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = group,
	callback = function()
		vim.cmd("silent! checktime")
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 40 })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "markdown",
	callback = function(event)
		vim.cmd("silent! UfoDetach")

		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.require'markdown_folds'.expr()"
		vim.opt_local.foldenable = true
		vim.opt_local.foldlevel = 99
		vim.opt_local.foldlevelstart = 99
		vim.opt_local.foldminlines = 2

		vim.keymap.set("n", "zO", function()
			vim.opt_local.foldlevel = 99
		end, { buffer = event.buf, desc = "Open all markdown folds" })

		vim.keymap.set("n", "zC", function()
			vim.opt_local.foldlevel = 0
		end, { buffer = event.buf, desc = "Close all markdown folds" })
	end,
})
