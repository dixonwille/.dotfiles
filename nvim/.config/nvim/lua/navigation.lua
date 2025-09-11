require("oil").setup()
vim.keymap.set({ "n" }, "-", "<cmd>Oil<cr>", { desc = "Open Oil" })

local picker = require('fzf-lua')
picker.setup()
picker.register_ui_select()

local todo_keywords = table.concat({
  "TODO",
  "WIP",
  "NOTE",
  "XXX",
  "INFO",
  "DOCS",
  "PERF",
  "TEST",
  "HACK",
  "WARNING",
  "WARN",
  "FIX",
  "FIXME",
  "BUG",
  "ERROR"
}, "|")
local reg_ex = ([[ \s?(?:KEYWORDS)(?:\s\(\w+\))?: ]]):gsub("KEYWORDS", todo_keywords)
local find_todos = function()
  picker.fzf_exec(
    "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -g '!.git' -e '" ..
    reg_ex .. "'",
    {
      ---@diagnostic disable-next-line: assign-type-mismatch
      actions = picker.defaults.actions.files,
      previewer = "builtin",
      winopts = { title = "TODOs" }
    })
end

vim.keymap.set({ "n" }, "<leader>ff", function() picker.files() end, { desc = "Find Files" })
vim.keymap.set({ "n" }, "<leader>fg", function() picker.live_grep() end, { desc = "Live Grep" })
vim.keymap.set({ "n" }, "<leader>fb", function() picker.buffers() end, { desc = "Find Buffers" })
vim.keymap.set({ "n" }, "<leader>fh", function() picker.helptags() end, { desc = "Find Help" })
vim.keymap.set({ "n" }, "<leader>ft", find_todos, { desc = "Find Todos" })
