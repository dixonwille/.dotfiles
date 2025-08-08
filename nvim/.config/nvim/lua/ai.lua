require("copilot").setup({
  panel = {
    enabled = false
  },
  sugestion = {
    enabled = false
  },
  filetypes = {
    ["*"] = false
  }
})

vim.g.codecompanion_auto_tool_mode = true -- Automatically allow all tools (can be dangerous but use a version control)
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = {
        name = "copilot",
        model = "gpt-5"
      }
    },
    inline = {
      adapter = {
        name = "copilot",
        model = "o4-mini"
      }
    },
    cmd = {
      adapter = {
        name = "copilot",
        model = "gpt-4.1"
      }
    },
  },
})

vim.keymap.set({ "n" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Open Chat" })
