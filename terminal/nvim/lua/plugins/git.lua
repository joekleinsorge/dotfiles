return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gwrite", "Gread", "Gdiffsplit", "Gclog" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>gl", "<cmd>Gclog<cr>", desc = "Git Commit Log" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame_opts = {
        delay = 300,
      },
    },
    keys = {
      {
        "<leader>gb",
        function()
          require("gitsigns").toggle_current_line_blame()
        end,
        desc = "Git Blame Toggle",
      },
      {
        "<leader>gB",
        function()
          require("gitsigns").blame_line { full = true }
        end,
        desc = "Git Blame Line (full)",
      },
      {
        "<leader>gp",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Git Preview Hunk",
      },
      {
        "<leader>gs",
        function()
          require("gitsigns").stage_hunk()
        end,
        desc = "Git Stage Hunk",
      },
      {
        "<leader>gS",
        function()
          require("gitsigns").stage_buffer()
        end,
        desc = "Git Stage Buffer",
      },
      {
        "<leader>gu",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
        desc = "Git Undo Stage Hunk",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_hunk()
        end,
        desc = "Git Reset Hunk",
      },
      {
        "<leader>gR",
        function()
          require("gitsigns").reset_buffer()
        end,
        desc = "Git Reset Buffer",
      },
      {
        "<leader>gn",
        function()
          require("gitsigns").next_hunk()
        end,
        desc = "Git Next Hunk",
      },
      {
        "<leader>gN",
        function()
          require("gitsigns").prev_hunk()
        end,
        desc = "Git Prev Hunk",
      },
    },
  },
}
