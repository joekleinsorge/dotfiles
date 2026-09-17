return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters.erb_lint.cmd = "erb_lint"
		lint.linters.erb_lint.args = {
			"--format",
			"compact",
			function()
				return vim.api.nvim_buf_get_name(0)
			end,
		}

		local function available(names)
			return vim.tbl_filter(function(name)
				return lint.linters[name] ~= nil
			end, names)
		end

		lint.linters_by_ft = {
			bash = available({ "shellcheck" }),
			eruby = available({ "erb_lint" }),
			markdown = available({ "markdownlint" }),
			python = available({ "ruff" }),
			sh = available({ "shellcheck" }),
			yaml = available({ "yamllint" }),
		}

		local group = vim.api.nvim_create_augroup("user_lint", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>lL", function()
			lint.try_lint()
		end, { desc = "Run Linter" })
	end,
}
