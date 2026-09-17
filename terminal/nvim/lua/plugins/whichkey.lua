return {
	"folke/which-key.nvim",
	lazy = false,
	opts = {
		notify = true,
		triggers = {
			{ "<leader>", mode = { "n", "v" } },
		},
		plugins = {
			marks = false,
			registers = false,
			spelling = {
				enabled = true,
				suggestions = 20,
			},
			presets = {
				operators = false,
				motions = false,
				text_objects = false,
				windows = false,
				nav = false,
				z = false,
				g = false,
			},
		},
		win = {
			border = "rounded",
			height = { min = 4, max = 25 },
			padding = { 1, 2 },
			wo = {
				winblend = 0,
			},
		},
		layout = {
			width = { min = 20, max = 50 },
			spacing = 3,
		},
		disable = {
			bt = {},
			ft = { "TelescopePrompt" },
		},
		spec = {
			{ "<leader>b", group = "Buffers" },
			{ "<leader>g", group = "Git" },
			{ "<leader>p", group = "Plugins" },
			{ "<leader>f", group = "Files" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>n", group = "Notes" },
			{ "<leader>s", group = "Search" },
			{ "<leader>x", group = "Diagnostics" },
			{ "<leader>l", group = "LSP", mode = "v" },
		},
	},
}
