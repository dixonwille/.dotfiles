require("oil").setup()
vim.keymap.set({ "n" }, "-", "<cmd>Oil<cr>", { desc = "Open Oil" })

local picker = require('mini.pick')
picker.setup()
vim.ui.select = picker.ui_select

local find_hidden = function()
  picker.builtin.cli({
    command = { "fd", "--hidden", "--type", "f", "--exclude", ".git", "--exclude", "node_modules" }
  }, {
    source = { name = "Find All Files" }
  })
end

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
  picker.builtin.cli({
    command = { "rg", "-Hn", "--column", reg_ex },
    --- @param items string[]
    postprocess = function(items)
      local new_items = {}
      for _, item in ipairs(items) do
        local filename, line, column, text = item:match("([^:]+):(%d+):(%d+):(.*)")
        if filename then
          new_items[#new_items + 1] = {
            text = string.format("%s:%s %s", filename, line, vim.trim(text)),
            path = filename,
            lnum = tonumber(line),
            col = tonumber(column)
          }
        end
      end
      return new_items
    end
  }, {
    source = {
      name = "Find Todos",
    }
  })
end

vim.keymap.set({ "n" }, "<leader>ff", "<cmd>Pick files<cr>", { desc = "Find Files" })
vim.keymap.set({ "n" }, "<leader>fa", find_hidden, { desc = "Find All Files" })
vim.keymap.set({ "n" }, "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Find Files" })
vim.keymap.set({ "n" }, "<leader>fb", "<cmd>Pick buffers<cr>", { desc = "Find Buffers" })
vim.keymap.set({ "n" }, "<leader>fh", "<cmd>Pick help<cr>", { desc = "Find Help" })
vim.keymap.set({ "n" }, "<leader>ft", find_todos, { desc = "Find Todos" })
