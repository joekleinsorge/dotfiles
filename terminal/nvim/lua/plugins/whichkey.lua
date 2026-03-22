local M = {
	"folke/which-key.nvim",
	lazy = false,
}

function M.config()
	local which_key = require("which-key")

	which_key.setup({
    notify = false,
		triggers = {
			{ "<leader>", mode = { "n", "v" } },
		},
		plugins = {
			marks = false, -- shows a list of your marks on ' and `
			registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
			spelling = {
				enabled = true,
				suggestions = 20,
			}, -- use which-key for spelling hints
			-- the presets plugin, adds help for a bunch of default keybindings in Neovim
			-- No actual key bindings are created
			presets = {
				operators = false, -- adds help for operators like d, y, ...
				motions = false, -- adds help for motions
				text_objects = false, -- help for text objects triggered after entering an operator
				windows = false, -- default bindings on <c-w>
				nav = false, -- misc bindings to work with windows
				z = false, -- bindings for folds, spelling and others prefixed with z
				g = false, -- bindings for prefixed with g
			},
		},
		-- popup_mappings = {
		-- 	scroll_down = "<c-d>", -- binding to scroll down inside the popup
		-- 	scroll_up = "<c-u>", -- binding to scroll up inside the popup
		-- },
		win = {
			border = "rounded", -- none, single, double, shadow
			position = "bottom", -- bottom, top
			margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
			padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
			winblend = 0,
		},
		layout = {
			height = { min = 4, max = 25 }, -- min and max height of the columns
			width = { min = 20, max = 50 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
			align = "left", -- align columns left, center or right
		},
		-- ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
		-- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
		show_help = true, -- show help message on the command line when the popup is visible
		show_keys = true, -- show the currently pressed key and its label as a message in the command line
		-- triggers = "auto", -- automatically setup triggers
		-- triggers = {"<leader>"} -- or specify a list manually
		-- triggers_blacklist = {
		-- 	-- list of mode / prefixes that should never be hooked by WhichKey
		-- 	-- this is mostly relevant for key maps that start with a native binding
		-- 	-- most people should not need to change this
		-- 	i = { "j", "k" },
		-- 	v = { "j", "k" },
		-- },
		-- disable the WhichKey popup for certain buf types and file types.
		-- Disabled by default for Telescope
		disable = {
			buftypes = {},
			filetypes = { "TelescopePrompt" },
		},
	})

	local normal_spec = {
		{ "<leader>t", group = "Terminal", nowait = true },
		{ "<leader>g", group = "Git", nowait = true },
		{ "<leader>p", group = "Plugins", nowait = true },
		{ "<leader>f", group = "Find", nowait = true },
		{ "<leader>l", group = "LSP", nowait = true },
		{ "<leader>n", group = "Notes", nowait = true },
		{ "<leader>w", group = "Window", nowait = true },
	}

	local visual_spec = {
		{ "<leader>/", "<Plug>(comment_toggle_linewise_visual)", desc = "Comment toggle linewise (visual)", nowait = true, remap = false },
		{ "<leader>l", group = "LSP", nowait = true },
		{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action", nowait = true, remap = false },
	}

	which_key.add(normal_spec)
	which_key.add(visual_spec, { mode = "v" })
end

return M
