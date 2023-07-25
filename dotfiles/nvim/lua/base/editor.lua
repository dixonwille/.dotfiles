return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "plenary.nvim"
    },
    cmd = "Telescope",
    keys = {
      {"<leader>ff", "<cmd>Telescope find_files<cr>", desc = "[F]ind [F]iles"},
      {"<leader>fb", "<cmd>Telescope buffers<cr>", desc = "[F]ind [B]uffers"},
      {"<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "[S]earch [A]utocommands"},
      {"<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "[S]earch with [G]rep"},
      {"<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "[S]earch [H]elp"},
      {"<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "[S]earch [K]eymaps"},
      {"<leader>st", "<cmd>TodoTelescope<cr>", desc = "[S]earch [T]odos"},
    },
    opts = {
      defaults = {
        initial_mode = "normal",
      },
    },
  },
}
