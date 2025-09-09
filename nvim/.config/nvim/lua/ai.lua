require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = 'claude_code'
    },
  },
  adapters = {
    acp = {
      claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = 'CLAUDE_CODE_OAUTH_TOKEN'
          }
        })
      end
    }
  }
})

vim.keymap.set({ "n" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Open Chat" })
