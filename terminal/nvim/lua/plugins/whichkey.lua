local M = {
	"folke/which-key.nvim",
	event = "VimEnter",
}

function M.config()
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

	local normal_spec = {
		{ "<leader>/", "<Plug>(comment_toggle_linewise_current)", desc = "Comment", nowait = true, remap = false },
		{ "<leader>b", "<cmd>Telescope buffers previewer=false<cr>", desc = "Find Buffer", nowait = true, remap = false },
		{ "<leader>c", "<cmd>bdelete<CR>", desc = "Close Buffer", nowait = true, remap = false },
		{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer", nowait = true, remap = false },
		{ "<leader>m", "<cmd>ZenMode<CR>", desc = "Zen Mode", nowait = true, remap = false },
		{ "<leader>q", "<cmd>confirm q<CR>", desc = "Quit", nowait = true, remap = false },
		{ "<leader>r", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it Rain", nowait = true, remap = false },
		{ "<leader>s", "<cmd>nohlsearch<CR>", desc = "No Highlight", nowait = true, remap = false },
		{ "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undo Tree", nowait = true, remap = false },

		{ "<leader>t", group = "Terminal", nowait = true },
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Last Terminal", nowait = true, remap = false },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating Terminal", nowait = true, remap = false },
		{ "<leader>th", "<cmd>ToggleTerm direction=horizontal size=0.3<cr>", desc = "Horizontal Terminal", nowait = true, remap = false },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical size=0.4<cr>", desc = "Vertical Terminal", nowait = true, remap = false },

		{ "<leader>g", group = "Git", nowait = true },
		{ "<leader>gg", "<cmd>Git<cr>", desc = "Status", nowait = true, remap = false },
		{ "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Blame", nowait = true, remap = false },
		{ "<leader>gB", "<cmd>Gitsigns blame_line<cr>", desc = "Blame Line Detail", nowait = true, remap = false },
		{ "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk", nowait = true, remap = false },
		{ "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage Hunk", nowait = true, remap = false },
		{ "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage Buffer", nowait = true, remap = false },
		{ "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo Stage Hunk", nowait = true, remap = false },
		{ "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Hunk", nowait = true, remap = false },
		{ "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Buffer", nowait = true, remap = false },
		{ "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Hunk", nowait = true, remap = false },
		{ "<leader>gN", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev Hunk", nowait = true, remap = false },
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview", nowait = true, remap = false },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diffview", nowait = true, remap = false },
		{ "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Diff Files", nowait = true, remap = false },
		{ "<leader>gF", "<cmd>DiffviewFocusFiles<cr>", desc = "Focus Diff Files", nowait = true, remap = false },
		{ "<leader>gl", "<cmd>Gclog<cr>", desc = "Commit Log", nowait = true, remap = false },

		{ "<leader>p", group = "Plugins", nowait = true },
		{ "<leader>pi", "<cmd>Lazy install<cr>", desc = "Install", nowait = true, remap = false },
		{ "<leader>ps", "<cmd>Lazy sync<cr>", desc = "Sync", nowait = true, remap = false },
		{ "<leader>pS", "<cmd>Lazy clear<cr>", desc = "Status", nowait = true, remap = false },
		{ "<leader>pc", "<cmd>Lazy clean<cr>", desc = "Clean", nowait = true, remap = false },
		{ "<leader>pu", "<cmd>Lazy update<cr>", desc = "Update", nowait = true, remap = false },
		{ "<leader>pp", "<cmd>Lazy profile<cr>", desc = "Profile", nowait = true, remap = false },
		{ "<leader>pl", "<cmd>Lazy log<cr>", desc = "Log", nowait = true, remap = false },
		{ "<leader>pd", "<cmd>Lazy debug<cr>", desc = "Debug", nowait = true, remap = false },

		{ "<leader>f", group = "Find", nowait = true },
		{ "<leader>fa", "<cmd>Telescope autocommands<cr>", desc = "Autocommands", nowait = true, remap = false },
		{ "<leader>fb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch", nowait = true, remap = false },
		{ "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme", nowait = true, remap = false },
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files", nowait = true, remap = false },
		{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git files", nowait = true, remap = false },
		{ "<leader>fp", "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = "Projects", nowait = true, remap = false },
		{ "<leader>fT", "<cmd>Telescope live_grep<cr>", desc = "Find Text", nowait = true, remap = false },
		{ "<leader>fs", "<cmd>Telescope grep_string<cr>", desc = "Find String", nowait = true, remap = false },
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help", nowait = true, remap = false },
		{ "<leader>fH", "<cmd>Telescope highlights<cr>", desc = "Highlights", nowait = true, remap = false },
		{ "<leader>fl", "<cmd>Telescope resume<cr>", desc = "Last Search", nowait = true, remap = false },
		{ "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages", nowait = true, remap = false },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent File", nowait = true, remap = false },
		{ "<leader>fR", "<cmd>Telescope registers<cr>", desc = "Registers", nowait = true, remap = false },
		{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps", nowait = true, remap = false },
		{ "<leader>fC", "<cmd>Telescope commands<cr>", desc = "Commands", nowait = true, remap = false },
		{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "ToDo", nowait = true, remap = false },
		{ "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Marks", nowait = true, remap = false },

		{ "<leader>l", group = "LSP", nowait = true },
		{ "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Declaration", nowait = true, remap = false },
		{ "<leader>lI", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Implementation", nowait = true, remap = false },
		{ "<leader>lM", "<cmd>Mason<cr>", desc = "Mason", nowait = true, remap = false },
		{ "<leader>lR", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "References", nowait = true, remap = false },
		{ "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols", nowait = true, remap = false },
		{ "<leader>lW", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", desc = "Buffer Diagnostics", nowait = true, remap = false },
		{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action", nowait = true, remap = false },
		{ "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Definition", nowait = true, remap = false },
		{ "<leader>le", "<cmd>Telescope quickfix<cr>", desc = "Telescope Quickfix", nowait = true, remap = false },
		{ "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", desc = "Format", nowait = true, remap = false },
		{ "<leader>lh", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature Help", nowait = true, remap = false },
		{ "<leader>li", "<cmd>LspInfo<cr>", desc = "Info", nowait = true, remap = false },
		{ "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic", nowait = true, remap = false },
		{ "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Prev Diagnostic", nowait = true, remap = false },
		{ "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action", nowait = true, remap = false },
		{ "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix", nowait = true, remap = false },
		{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename", nowait = true, remap = false },
		{ "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols", nowait = true, remap = false },
		{ "<leader>lt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", desc = "Type Definition", nowait = true, remap = false },
		{ "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics", nowait = true, remap = false },

		{ "<leader>n", group = "Notes", nowait = true },
		{ "<leader>nn", "<cmd>lua require 'notes'.new_note()<cr>", desc = "New Note", nowait = true, remap = false },
		{ "<leader>nl", "<cmd>lua require 'notes'.last_note()<cr>", desc = "Last Note", nowait = true, remap = false },
		{ "<leader>nf", "<cmd>lua require 'notes'.find_note()<cr>", desc = "Find Note", nowait = true, remap = false },
		{ "<leader>ns", "<cmd>lua require 'notes'.search_notes()<cr>", desc = "Search Notes", nowait = true, remap = false },

		{ "<leader>w", group = "Window", nowait = true },
		{ "<leader>w=", "<C-w>=", desc = "Balance Windows", nowait = true, remap = false },
		{ "<leader>wh", "<C-w>h", desc = "Left", nowait = true, remap = false },
		{ "<leader>wj", "<C-w>j", desc = "Down", nowait = true, remap = false },
		{ "<leader>wk", "<C-w>k", desc = "Up", nowait = true, remap = false },
		{ "<leader>wl", "<C-w>l", desc = "Right", nowait = true, remap = false },
		{ "<leader>wq", "<cmd>close<cr>", desc = "Close Window", nowait = true, remap = false },
		{ "<leader>ws", "<cmd>split<cr>", desc = "Horizontal Split", nowait = true, remap = false },
		{ "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical Split", nowait = true, remap = false },
		{ "<leader>ww", "<C-w>w", desc = "Next Window", nowait = true, remap = false },
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
