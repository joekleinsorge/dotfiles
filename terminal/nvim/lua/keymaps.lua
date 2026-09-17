local function map(mode, lhs, rhs, desc, opts)
	local options = { noremap = true, silent = true }
	if desc then
		options.desc = desc
	end
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

map({ "n", "v" }, "<Space>", "<Nop>")

map("n", "<leader><space>", function()
	local ok, wk = pcall(require, "which-key")
	if ok then
		wk.show("<leader>")
		return
	end
	vim.cmd("WhichKey \\<space>")
end, "Show keymaps")

map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", "Find files")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", "Find buffers")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", "Recent files")

map("n", "<leader>ss", "<cmd>Telescope live_grep<CR>", "Search text")
map("n", "<leader>sw", "<cmd>Telescope grep_string<CR>", "Search word")
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<CR>", "Search buffer")
map("n", "<leader>sr", "<cmd>Telescope resume<CR>", "Resume search")
map("n", "<leader>sh", "<cmd>Telescope help_tags<CR>", "Search help")
map("n", "<leader>sc", "<cmd>Telescope commands<CR>", "Search commands")

map("n", "<leader>pl", "<cmd>Lazy<CR>", "Lazy")
map("n", "<leader>pm", "<cmd>Mason<CR>", "Mason")

map("n", "<leader>bb", "<C-^>", "Alternate buffer")

map({ "n", "v" }, "L", "$", "Go line end")
map({ "n", "v" }, "H", "^", "Go line start")

map("n", "<m-h>", "<C-w>h", "Window left")
map("n", "<m-j>", "<C-w>j", "Window down")
map("n", "<m-k>", "<C-w>k", "Window up")
map("n", "<m-l>", "<C-w>l", "Window right")
map("n", "<m-tab>", "<c-6>", "Alternate file")

map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")
map("n", "n", "nzzzv", "Next match centered")
map("n", "N", "Nzzzv", "Prev match centered")
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

map("x", "p", [["_dP]], "Paste replace without yank")

vim.cmd([[:amenu 10.100 mousemenu.Goto\ Definition <cmd>lua vim.lsp.buf.definition()<CR>]])
vim.cmd([[:amenu 10.110 mousemenu.References <cmd>lua vim.lsp.buf.references()<CR>]])
map("n", "<RightMouse>", "<cmd>:popup mousemenu<CR>", "Mouse context menu")

map("n", "Q", "<Nop>", "Disable macro recording")
