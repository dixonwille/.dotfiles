-- TODO (wd): include treesitter
-- TODO (wd): include mason
-- TODO (wd): should I handle Razor?

vim.lsp.config("roslyn_ls", {
  cmd = {
    "roslyn",
    "--logLevel",
    "Information",
    "--extensionLogDirectory",
    vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
    "--stdio",
  },
})

vim.lsp.enable({ "roslyn_ls" })
