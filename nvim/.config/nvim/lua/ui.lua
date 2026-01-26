require("vague").setup({
  on_highlights = function(groups, c)
    groups.CurSearch = { fg = c.bg, bg = c.search, bold = true }
    groups.IncSearch = { link = 'CurSearch' }
    groups["@lsp.type.comment"] = {}
  end,
})
vim.cmd.colorscheme("vague")

require('mini.icons').setup()
require("mini.statusline").setup()
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
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
        components = {
          kind_icon = {
            text = function(ctx)
              local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
              return kind_icon
            end,
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          },
          kind = {
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          }
        }
      }
    }
  }
})
