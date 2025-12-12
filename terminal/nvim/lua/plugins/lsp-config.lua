return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
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
    opts = {
      ensure_installed = { "tsserver", "solargraph", "html", "lua_ls" },
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local function map(bufnr, mode, lhs, rhs, desc)
        local opts = { buffer = bufnr, desc = desc }
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      local servers = {
        tsserver = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        solargraph = {},
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

      local function on_attach(client, bufnr)
        map(bufnr, "n", "K", vim.lsp.buf.hover, "LSP Hover")
        map(bufnr, "n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
        map(bufnr, "n", "<leader>ld", vim.lsp.buf.definition, "Goto Definition")
        map(bufnr, "n", "<leader>lD", vim.lsp.buf.declaration, "Goto Declaration")
        map(bufnr, "n", "<leader>lI", vim.lsp.buf.implementation, "Goto Implementation")
        map(bufnr, "n", "<leader>lR", vim.lsp.buf.references, "Goto References")
        map(bufnr, "n", "<leader>lt", vim.lsp.buf.type_definition, "Type Definition")
        map(bufnr, "n", "<leader>lf", function()
          vim.lsp.buf.format({ async = true })
        end, "Format Buffer")
        map(bufnr, "n", "<leader>lj", vim.diagnostic.goto_next, "Next Diagnostic")
        map(bufnr, "n", "<leader>lk", vim.diagnostic.goto_prev, "Prev Diagnostic")
        map(bufnr, "n", "<leader>lq", vim.diagnostic.setloclist, "Send Diagnostics to Loclist")
        map(bufnr, "n", "<leader>ll", vim.lsp.codelens.run, "Run CodeLens")
        map(bufnr, "n", "<leader>lh", vim.lsp.buf.signature_help, "Signature Help")
        map(bufnr, "n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols")
        map(bufnr, "n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols")
        map(bufnr, "n", "<leader>lw", "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostics")
        map(bufnr, "n", "<leader>lW", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics")
        map(bufnr, "n", "<leader>le", "<cmd>Telescope quickfix<cr>", "Telescope Quickfix")
      end

      for server, opts in pairs(servers) do
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
        }, opts)

        local server_specific_on_attach = server_opts.on_attach
        server_opts.on_attach = function(client, bufnr)
          if type(server_specific_on_attach) == "function" then
            server_specific_on_attach(client, bufnr)
          end
          on_attach(client, bufnr)
        end

        lspconfig[server].setup(server_opts)
      end

      vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
      vim.keymap.set("n", "<leader>lM", "<cmd>Mason<cr>", { desc = "Mason" })
    end,
  },
}
