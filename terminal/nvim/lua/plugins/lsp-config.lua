local servers = {
	"bashls",
	"cssls",
	"docker_compose_language_service",
	"dockerls",
	"eslint",
	"gopls",
	"html",
	"jsonls",
	"lua_ls",
	"marksman",
	"pyright",
	"solargraph",
	"tailwindcss",
	"taplo",
	"terraformls",
	"ts_ls",
	"yamlls",
}

if vim.fn.executable("nix") == 1 then
	table.insert(servers, "nil_ls")
end

local tools = {
	"erb-lint",
	"jq",
	"markdownlint",
	"prettier",
	"rubocop",
	"ruff",
	"shellcheck",
	"shfmt",
	"stylua",
	"yamlfmt",
	"yamllint",
}

return {
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		lazy = true,
		opts = {
			ensure_installed = servers,
			automatic_enable = false,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
		lazy = true,
		opts = {
			ensure_installed = tools,
			auto_update = false,
			run_on_start = false,
			start_delay = 3000,
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local function map(bufnr, mode, lhs, rhs, desc)
				local opts = { buffer = bufnr, desc = desc }
				vim.keymap.set(mode, lhs, rhs, opts)
			end

			local function jump_diagnostic(count)
				return function()
					vim.diagnostic.jump({ count = count, float = true })
				end
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local server_configs = {
				bashls = {},
				cssls = {},
				docker_compose_language_service = {},
				dockerls = {},
				eslint = {},
				gopls = {},
				jsonls = {},
				marksman = {},
				pyright = {},
				solargraph = {},
				tailwindcss = {},
				taplo = {},
				terraformls = {},
				ts_ls = {
					on_attach = function(client)
						client.server_capabilities.documentFormattingProvider = false
					end,
				},
				html = {
					on_attach = function(client)
						client.server_capabilities.documentFormattingProvider = false
					end,
				},
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = {
								checkThirdParty = false,
							},
							telemetry = { enable = false },
						},
					},
				},
			}

			if vim.fn.executable("nix") == 1 then
				server_configs.nil_ls = {}
			end

			local function on_attach(client, bufnr)
				map(bufnr, "n", "K", vim.lsp.buf.hover, "LSP Hover")
				map(bufnr, "n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
				map(bufnr, "n", "<leader>ld", vim.lsp.buf.definition, "Goto Definition")
				map(bufnr, "n", "<leader>lD", vim.lsp.buf.declaration, "Goto Declaration")
				map(bufnr, "n", "<leader>lI", vim.lsp.buf.implementation, "Goto Implementation")
				map(bufnr, "n", "<leader>lR", vim.lsp.buf.references, "Goto References")
				map(bufnr, "n", "<leader>lt", vim.lsp.buf.type_definition, "Type Definition")
				map(bufnr, "n", "<leader>lj", jump_diagnostic(1), "Next Diagnostic")
				map(bufnr, "n", "<leader>lk", jump_diagnostic(-1), "Previous Diagnostic")
				map(bufnr, "n", "<leader>lq", vim.diagnostic.setloclist, "Send Diagnostics to Loclist")
				map(bufnr, "n", "<leader>ll", vim.lsp.codelens.run, "Run CodeLens")
				map(bufnr, "n", "<leader>lh", vim.lsp.buf.signature_help, "Signature Help")
				map(bufnr, "n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols")
				map(bufnr, "n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols")
				map(bufnr, "n", "<leader>lw", "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostics")
				map(
					bufnr,
					"n",
					"<leader>lW",
					"<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>",
					"Buffer Diagnostics"
				)
				map(bufnr, "n", "<leader>le", "<cmd>Telescope quickfix<cr>", "Telescope Quickfix")
			end

			for server, opts in pairs(server_configs) do
				local server_specific_on_attach = opts.on_attach
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
				}, opts)

				server_opts.on_attach = function(client, bufnr)
					if type(server_specific_on_attach) == "function" then
						server_specific_on_attach(client, bufnr)
					end
					on_attach(client, bufnr)
				end

				vim.lsp.config(server, server_opts)
				vim.lsp.enable(server)
			end

			vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
		end,
	},
}
