-- TODO (wd): include treesitter
-- TODO (wd): include mason

vim.lsp.config("bicep", {
  cmd = { "bicep-lsp" },
})

vim.lsp.enable({ "bicep" })
