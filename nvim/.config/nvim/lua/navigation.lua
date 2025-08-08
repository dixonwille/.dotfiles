require("oil").setup()
vim.keymap.set({ "n" }, "-", "<cmd>Oil<cr>", { desc = "Open Oil" })

local picker = require('mini.pick')
picker.setup()
vim.ui.select = picker.ui_select

vim.keymap.set({ "n" }, "<leader>ff", "<cmd>Pick files<cr>", { desc = "Find Files" })
vim.keymap.set({ "n" }, "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Find Files" })
vim.keymap.set({ "n" }, "<leader>fb", "<cmd>Pick buffers<cr>", { desc = "Find Buffers" })
vim.keymap.set({ "n" }, "<leader>fh", "<cmd>Pick help<cr>", { desc = "Find Help" })
