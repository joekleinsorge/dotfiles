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

local function with_plugin(module, plugin, callback)
  return function()
    local ok, mod = pcall(require, module)
    if not ok then
      local lazy_ok, lazy = pcall(require, "lazy")
      if lazy_ok then
        lazy.load { plugins = { plugin } }
        ok, mod = pcall(require, module)
      end
    end

    if not ok then
      vim.notify(("Module %s is not available"):format(module), vim.log.levels.WARN)
      return
    end

    callback(mod)
  end
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
end, "which-key: show <leader>")

map("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", "Cellular automaton (rain)")

map("n", "<leader>nn", with_plugin("notes", "notes.nvim", function(notes)
  notes.new_note()
end), "Notes: new")
map("n", "<leader>nl", with_plugin("notes", "notes.nvim", function(notes)
  notes.last_note()
end), "Notes: last")
map("n", "<leader>nf", with_plugin("notes", "notes.nvim", function(notes)
  notes.find_note()
end), "Notes: find")
map("n", "<leader>ns", with_plugin("notes", "notes.nvim", function(notes)
  notes.search_notes()
end), "Notes: search")

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
map("n", "<Tab>", "<cmd>:popup mousemenu<CR>", "Mouse context menu")

map("n", "<leader>u", vim.cmd.UndotreeToggle, "Undo tree")

map("n", "Q", "<Nop>", "Disable macro recording")
