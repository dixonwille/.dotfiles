vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection Up" })

vim.keymap.set({ "n", "v" }, "<Leader>y", '"+y', { desc = "[Y]ank selection to system" })
vim.keymap.set("n", "<Leader>Y", '"+Y', { desc = "[Y]ank line to system" })

vim.keymap.set({ "n", "v" }, "<Leader>p", '"+p', { desc = "[P]aste after from system" })
vim.keymap.set("n", "<Leader>P", '"+P', { desc = "[P]aste before from system" })

-- Lazy
vim.keymap.set("n", "<Leader>cl", "<cmd>Lazy show<cr>", { desc = "[C]heck [L]azy" })

