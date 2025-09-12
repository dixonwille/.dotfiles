vim.g.mapleader = " " -- Set leader key to space
vim.o.exrc = true -- Support .nvim.lua files
vim.o.number = true -- Show the current line number cursor is on instead of 0
vim.o.relativenumber = true -- Show line numbers relative to cursor
vim.o.colorcolumn = "80" -- Set column
vim.o.listchars = "eol:↴,space:⋅,tab:>-,nbsp:+" -- set characters to show when list is set
vim.o.signcolumn = "yes" -- Always show sign column to stop flickering
vim.o.wrap = false -- disable wrap by default
vim.o.swapfile = false -- Turn off the swapfile
vim.o.backup = false -- Turn off the backup file
vim.o.incsearch = true -- Want to show search while searching
vim.o.tabstop = 2 -- Set default tab size to 2
vim.o.shiftwidth = 2 -- Set default tab size to 2
vim.o.expandtab = true -- Expand tabs to spaces by default
vim.o.undofile = true -- Allow undoing a file even after closing vim
vim.o.completeopt = "menuone,noselect,popup" -- Settings for the autocomplete popup
vim.o.winborder = "rounded" -- Make floating windows have a rounded border
vim.o.ignorecase = true -- Ignore casing when searching
vim.o.smartcase = true -- Turn off Ignore case when a capital letter is detected
vim.o.termguicolors = true -- turn on 24-bit colors

vim.keymap.set({ "v" }, "J", ":m '>+1<CR>gv=gv", { desc = "Move selection Down" })
vim.keymap.set({ "v" }, "K", ":m '<-2<CR>gv=gv", { desc = "Move selection Up" })
vim.keymap.set({ "n", "v" }, "<Leader>y", '"+y', { desc = "Yank selection to system" })
vim.keymap.set({ "n" }, "<Leader>Y", '"+Y', { desc = "Yank line to system" })
vim.keymap.set({ "n", "v" }, "<Leader>p", '"+p', { desc = "Paste after from system" })
vim.keymap.set({ "n" }, "<Leader>P", '"+P', { desc = "Paste before from system" })
vim.keymap.set({ "n" }, "<C-f>", '<cmd>silent !tmux neww tmux-sessionizer<CR>', { desc = "Switch Projects" })

--- @param name string
local function safe_require(name)
  local status, obj = pcall(require, name)
  if not status then
    vim.notify("Could not load '" .. name .. "':\n" .. obj, vim.log.levels.WARN, {})
    return nil
  end
  return obj
end

require("packages") -- This is what installs all the plugins and is a must
safe_require("ui")
safe_require("navigation")
safe_require("languages")
