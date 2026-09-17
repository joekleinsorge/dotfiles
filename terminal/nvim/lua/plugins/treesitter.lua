local parsers = {
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"go",
	"gomod",
	"gosum",
	"hcl",
	"html",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"markdown_inline",
	"nix",
	"python",
	"query",
	"regex",
	"ruby",
	"scss",
	"sql",
	"terraform",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local indent_filetypes = {
	bash = true,
	css = true,
	dockerfile = true,
	go = true,
	html = true,
	javascript = true,
	json = true,
	jsonc = true,
	lua = true,
	nix = true,
	python = true,
	ruby = true,
	scss = true,
	terraform = true,
	toml = true,
	tsx = true,
	typescript = true,
	yaml = true,
}

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup({})
		if vim.env.NVIM_SMOKE_TEST ~= "1" then
			treesitter.install(parsers)
		end

		local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(event)
				local filetype = vim.bo[event.buf].filetype
				local language = vim.treesitter.language.get_lang(filetype) or filetype
				local started = pcall(vim.treesitter.start, event.buf, language)

				if started and indent_filetypes[filetype] then
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
