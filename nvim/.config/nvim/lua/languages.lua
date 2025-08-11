vim.treesitter.language.register("bash", "zsh")
vim.treesitter.language.register("vimdoc", "help")

require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
})
vim.keymap.set({ "n" }, "<leader>cm", "<cmd>Mason<cr>", { desc = "Check Mason" })

---@param bufnr integer
local function enable_ts(bufnr)
  vim.treesitter.start(bufnr)
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.wo.foldlevel = 999
  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local nvimts = require("nvim-treesitter")
-- WARN: neovim expects some of these to be installed
nvimts.install({ "c", "lua", "markdown", "markdown_inline", "query", "vim", "vimdoc", "comment", "yaml" })

---Try and enable treesitter
---@param bufnr integer
---@param filetype string
local function try_enable(bufnr, filetype)
  local ft = vim.treesitter.language.get_lang(filetype)
  local installed = nvimts.get_installed()
  if vim.tbl_contains(installed, ft, {}) then
    enable_ts(bufnr)
    return
  end
  local avail = nvimts.get_available()
  if vim.tbl_contains(avail, ft, {}) then
    nvimts.install(ft):await(function()
      enable_ts(bufnr)
    end)
  end
end

local tsaug = vim.api.nvim_create_augroup("TreesitterFT", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "Setup Treesitter for filetypes",
  group = tsaug,
  callback = function(opt)
    try_enable(opt.buf, opt.match)
  end,
})

require("languages.lua")


local aug = vim.api.nvim_create_augroup("Lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  desc = "Lint after save",
  pattern = "*",
  group = aug,
  callback = function()
    require("lint").try_lint()
  end,
})

require("conform").setup({
  formatters_by_ft = {},
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
})
