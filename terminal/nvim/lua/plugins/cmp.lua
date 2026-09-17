local M = {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"saadparwaiz1/cmp_luasnip",
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
		{
			"zbirenbaum/copilot-cmp",
			enabled = vim.env.NVIM_SMOKE_TEST ~= "1",
			dependencies = {
				{
					"zbirenbaum/copilot.lua",
					cmd = "Copilot",
					event = "InsertEnter",
					opts = {
						suggestion = { enabled = false },
						panel = { enabled = false },
					},
				},
			},
			config = function()
				require("copilot_cmp").setup({})
			end,
		},
	},
}

function M.config()
	vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

	local cmp = require("cmp")
	local luasnip = require("luasnip")
	require("luasnip/loaders/from_vscode").lazy_load()
	luasnip.filetype_extend("typescriptreact", { "html" })

	local icons = require("icons")

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		preselect = cmp.PreselectMode.None,
		mapping = cmp.mapping.preset.insert({
			["<C-k>"] = cmp.mapping.select_prev_item(),
			["<C-j>"] = cmp.mapping.select_next_item(),
			["<Down>"] = cmp.mapping.select_next_item(),
			["<Up>"] = cmp.mapping.select_prev_item(),
			["<C-b>"] = cmp.mapping.scroll_docs(-1),
			["<C-f>"] = cmp.mapping.scroll_docs(1),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = false }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
		formatting = {
			fields = { "kind", "abbr" },
			format = function(entry, item)
				item.kind = icons.kind[item.kind]
				if entry.source.name == "copilot" then
					item.kind = icons.git.Octoface
					item.kind_hl_group = "CmpItemKindCopilot"
				end
				return item
			end,
		},
		sources = vim.list_extend(vim.env.NVIM_SMOKE_TEST == "1" and {} or { { name = "copilot" } }, {
			{ name = "lazydev", group_index = 0 },
			{
				name = "nvim_lsp",
				entry_filter = function(entry, ctx)
					return ctx.prev_context.filetype == "markdown"
						or entry:get_kind() ~= vim.lsp.protocol.CompletionItemKind.Text
				end,
			},
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "buffer" },
		}),
		confirm_opts = {
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		},
		window = {
			completion = {
				border = "rounded",
				winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,FloatBorder:FloatBorder,Search:None",
				col_offset = -3,
				side_padding = 1,
				scrollbar = false,
				scrolloff = 8,
			},
			documentation = {
				border = "rounded",
				winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,Search:None",
			},
		},
	})

	if M.confirm_done then
		cmp.event:off("confirm_done", M.confirm_done)
	end
	M.confirm_done = require("nvim-autopairs.completion.cmp").on_confirm_done()
	cmp.event:on("confirm_done", M.confirm_done)
end

return M
