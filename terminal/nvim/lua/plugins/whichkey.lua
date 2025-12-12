local M = {
	"folke/which-key.nvim",
	event = "VeryLazy",
}

function M.config()
	local mappings = {
		["q"] = { "<cmd>confirm q<CR>", "Quit" },
		["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment" },
		["s"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
		["c"] = { "<cmd>bdelete<CR>", "Close Buffer" },
		["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
		["b"] = { "<cmd>Telescope buffers previewer=false<cr>", "Find Buffer" },
		["u"] = { "<cmd>UndotreeToggle<CR>", "Undo Tree" },
		["m"] = { "<cmd>ZenMode<CR>", "Zen Mode" },
		["r"] = { "<cmd>CellularAutomaton make_it_rain<CR>", "Make it Rain" },
		["t"] = {
			name = "Terminal",
			t = { "<cmd>ToggleTerm<cr>", "Last Terminal" },
			f = { "<cmd>ToggleTerm direction=float<cr>", "Floating Terminal" },
			h = { "<cmd>ToggleTerm direction=horizontal size=0.3<cr>", "Horizontal Terminal" },
			v = { "<cmd>ToggleTerm direction=vertical size=0.4<cr>", "Vertical Terminal" },
		},
		["g"] = {
			name = "Git",
			g = { "<cmd>Git<cr>", "Status" },
			b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle Blame" },
			B = { "<cmd>Gitsigns blame_line<cr>", "Blame Line Detail" },
			p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview Hunk" },
			s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk" },
			S = { "<cmd>Gitsigns stage_buffer<cr>", "Stage Buffer" },
			u = { "<cmd>Gitsigns undo_stage_hunk<cr>", "Undo Stage Hunk" },
			r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
			R = { "<cmd>Gitsigns reset_buffer<cr>", "Reset Buffer" },
			n = { "<cmd>Gitsigns next_hunk<cr>", "Next Hunk" },
			N = { "<cmd>Gitsigns prev_hunk<cr>", "Prev Hunk" },
			d = { "<cmd>DiffviewOpen<cr>", "Diffview" },
			D = { "<cmd>DiffviewClose<cr>", "Close Diffview" },
			f = { "<cmd>DiffviewToggleFiles<cr>", "Toggle Diff Files" },
			F = { "<cmd>DiffviewFocusFiles<cr>", "Focus Diff Files" },
			l = { "<cmd>Gclog<cr>", "Commit Log" },
		},
		p = {
			name = "Plugins",
			i = { "<cmd>Lazy install<cr>", "Install" },
			s = { "<cmd>Lazy sync<cr>", "Sync" },
			S = { "<cmd>Lazy clear<cr>", "Status" },
			c = { "<cmd>Lazy clean<cr>", "Clean" },
			u = { "<cmd>Lazy update<cr>", "Update" },
			p = { "<cmd>Lazy profile<cr>", "Profile" },
			l = { "<cmd>Lazy log<cr>", "Log" },
			d = { "<cmd>Lazy debug<cr>", "Debug" },
		},
		f = {
			name = "Find",
			a = { "<cmd>Telescope autocommands<cr>", "Autocommands" },
			b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
			c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
			f = { "<cmd>Telescope find_files<cr>", "Find files" },
			g = { "<cmd>Telescope git_files<cr>", "Git files" },
			p = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
			T = { "<cmd>Telescope live_grep<cr>", "Find Text" },
			s = { "<cmd>Telescope grep_string<cr>", "Find String" },
			h = { "<cmd>Telescope help_tags<cr>", "Help" },
			H = { "<cmd>Telescope highlights<cr>", "Highlights" },
			l = { "<cmd>Telescope resume<cr>", "Last Search" },
			M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
			r = { "<cmd>Telescope oldfiles<cr>", "Recent File" },
			R = { "<cmd>Telescope registers<cr>", "Registers" },
			k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
			C = { "<cmd>Telescope commands<cr>", "Commands" },
			t = { "<cmd>TodoTelescope<cr>", "ToDo" },
			m = { "<cmd>Telescope marks<cr>", "Marks" },
		},
		l = {
			name = "LSP",
			a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
			d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
			D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Declaration" },
			f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format" },
			i = { "<cmd>LspInfo<cr>", "Info" },
			I = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Implementation" },
			M = { "<cmd>Mason<cr>", "Mason" },
			j = {
				"<cmd>lua vim.diagnostic.goto_next()<cr>",
				"Next Diagnostic",
			},
			k = {
				"<cmd>lua vim.diagnostic.goto_prev()<cr>",
				"Prev Diagnostic",
			},
			l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
			q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
			r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
			R = { "<cmd>lua vim.lsp.buf.references()<cr>", "References" },
			s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
			S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
			t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type Definition" },
			w = { "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostics" },
			W = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
			e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
			h = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature Help" },
		},
		n = {
			name = "Notes",
			l = { "<cmd>lua require 'notes'.last_note()<cr>", "Last Note"},
			n = { "<cmd>lua require 'notes'.new_note()<cr>", "New Note" },
			f = { "<cmd>lua require 'notes'.find_note()<cr>", "Find Note" },
			s = { "<cmd>lua require 'notes'.search_notes()<cr>", "Search Notes" },
		},
		w = {
			name = "Window",
			h = { "<C-w>h", "Left" },
			j = { "<C-w>j", "Down" },
			k = { "<C-w>k", "Up" },
			l = { "<C-w>l", "Right" },
			s = { "<cmd>split<cr>", "Horizontal Split" },
			v = { "<cmd>vsplit<cr>", "Vertical Split" },
			w = { "<C-w>w", "Next Window" },
			q = { "<cmd>close<cr>", "Close Window" },
			["="] = { "<C-w>=", "Balance Windows" },
		},
  }

	local opts = {
		mode = "n", -- NORMAL mode
		prefix = "<leader>",
		buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		silent = true, -- use `silent` when creating keymaps
		noremap = true, -- use `noremap` when creating keymaps
		nowait = true, -- use `nowait` when creating keymaps
	}

	local vmappings = {
		["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment toggle linewise (visual)" },
		l = {
			name = "LSP",
			a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
		},
	}

	local vopts = {
		mode = "v", -- VISUAL mode
		prefix = "<leader>",
		buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		silent = true, -- use `silent` when creating keymaps
		noremap = true, -- use `noremap` when creating keymaps
		nowait = true, -- use `nowait` when creating keymaps
	}

	local which_key = require("which-key")

	which_key.setup({
    notify = false,
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

	which_key.register(mappings, opts)
	which_key.register(vmappings, vopts)
end

return M
