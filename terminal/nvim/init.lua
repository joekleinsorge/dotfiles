local plugin_data = vim.env.NVIM_SMOKE_DATA_DIR or vim.fn.stdpath("data")
local lazypath = plugin_data .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
if vim.env.NVIM_SMOKE_DATA_DIR then
	vim.opt.rtp:append(vim.env.NVIM_SMOKE_DATA_DIR .. "/site")
end
require("options")
require("autocmds")
require("keymaps")
require("lazy").setup("plugins", {
	root = plugin_data .. "/lazy",
	rocks = { enabled = false },
	install = {
		missing = vim.env.NVIM_SMOKE_TEST ~= "1",
	},
	checker = {
		enabled = vim.env.NVIM_SMOKE_TEST ~= "1",
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
