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
    "--stdio"
  },
  -- Re-enable workspace file-watching on Linux. Neovim's default
  -- make_client_capabilities() sets dynamicRegistration = false on Linux/BSD
  -- (see runtime/lua/vim/lsp/protocol.lua), which causes Roslyn LS to fall
  -- back to its in-process watcher and makes project load take minutes.
  -- Deep-merged on top of nvim-lspconfig's capabilities block.
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
})

vim.lsp.enable({ "roslyn_ls" })
