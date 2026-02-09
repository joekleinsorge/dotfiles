local M = {
  "ahmedkhalf/project.nvim",
  event = "VeryLazy",
}

function M.config()
  require("project_nvim").setup {
    detection_methods = { "lsp", "pattern" },
    patterns = { ".git", ".hg", ".svn", "Makefile", "package.json" },
  }
end

return M
