local M = {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    { "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview Files" },
    { "<leader>gF", "<cmd>DiffviewFocusFiles<cr>", desc = "Diffview Focus Files" },
  },
}

function M.config() end

return M
