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

require("mcphub").setup({
  auto_approve = true,
  global_env = {
    PROJECT_ROOT = vim.fn.getcwd()
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
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_tools = true,
        show_server_tools_in_chat = true,
        add_mcp_prefix_to_tool_names = false,
        show_result_in_chat = true,
        make_vars = true,
        make_slash_commands = true,
      }
    }
  }
})

vim.keymap.set({ "n" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Open Chat" })
