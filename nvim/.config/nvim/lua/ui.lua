vim.cmd.colorscheme("tokyonight-night")
vim.api.nvim_set_hl(0, '@lsp.type.comment', {})

require("mini.statusline").setup()
require("mini.tabline").setup()
require('mini.notify').setup()

require('vim._extui').enable({
  msg = {
    target = 'msg',
  }
})

require("luasnip.loaders.from_vscode").lazy_load()
require("blink.cmp").setup({
  signature = { enabled = true },
  snippets = { preset = 'luasnip' },
  sources = {
    per_filetype = {
      codecompanion = { "codecompanion" }
    }
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
      }
    }
  }
})
