-- Completion with blink.cmp (v1).
--
-- Neovim's built-in completion ('autocomplete' + vim.lsp.completion) was tried
-- and works, but these blink features weren't worth rebuilding by hand:
-- - Signature help that opens on "(" and follows along while typing arguments,
--   highlighting the current parameter. The built-in float closes on the next
--   keystroke, so keeping it open needs fiddly timing code.
-- - A documentation window it draws itself: wrapped at word boundaries,
--   bordered, and scrollable with <C-f>/<C-b>. The built-in popup has none of
--   these (and neither renders through render-markdown).
-- - Fuzzy matching with frecency, plus path and buffer words next to the LSP.
--
-- blink v2 (unreleased as of 2026-09) mostly reworks internals; worth a look
-- once 2.0 is tagged, e.g. for cmdline ghost text with ui2.

local function icon(ctx)
  local glyph, hl = require("mini.icons").get("lsp", ctx.kind)
  return glyph, hl
end

require("blink.cmp").setup({
  -- No snippet source; LSP snippets still expand through vim.snippet
  sources = { default = { "lsp", "path", "buffer" } },
  signature = { enabled = true },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
        components = {
          kind_icon = {
            text = function(ctx) return (icon(ctx)) end,
            highlight = function(ctx) return select(2, icon(ctx)) end,
          },
          kind = {
            highlight = function(ctx) return select(2, icon(ctx)) end,
          },
        },
      },
    },
  },
})
