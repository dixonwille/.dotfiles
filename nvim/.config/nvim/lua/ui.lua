require("vague").setup({
  on_highlights = function(groups, c)
    groups.CurSearch = { fg = c.bg, bg = c.search, bold = true }
    groups.IncSearch = { link = "CurSearch" }
    groups["@lsp.type.comment"] = {}
  end,
})
vim.cmd.colorscheme("vague")

require("mini.icons").setup()
require("statusline")

require("vim._core.ui2").enable({
  msg = {
    -- Default for messages not routed by `targets`. Undocumented (only a string
    -- `targets` sets it officially), but a table `targets` resets it to "cmd".
    target = "msg",
    -- Output I asked for goes to the scrollable pager (which takes the cursor);
    -- everything else stays in the ephemeral msg window
    targets = {
      typed_cmd = "pager",
      list_cmd = "pager",
      shell_out = "pager",
      shell_err = "pager",
    },
  },
})

require("render-markdown").setup({})
