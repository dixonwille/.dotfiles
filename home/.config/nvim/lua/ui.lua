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
    -- Listings and shell output go to the scrollable pager (which takes the
    -- cursor); everything else stays in the ephemeral msg window (`g<` opens it
    -- in the pager). Don't route the "typed_cmd" trigger here: it covers every
    -- message from a typed command, so `:w`'s "written" would open the pager
    -- and pull the cursor out of the buffer on every save.
    targets = {
      list_cmd = "pager",
      shell_out = "pager",
      shell_err = "pager",
    },
  },
})

require("render-markdown").setup({})
