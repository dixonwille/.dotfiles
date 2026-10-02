-- Python (python toolchain): ruff and ty run the project's own copy from its
-- .venv (pinned in its dev dependencies, so the same version as everyone else),
-- falling back to the toolchain's, like nvim-lspconfig does with node_modules/.bin.
-- Formatting is ruff's server.

---@param tool string
---@return fun(dispatchers: vim.lsp.rpc.Dispatchers, config: vim.lsp.ClientConfig): vim.lsp.rpc.PublicClient
local function venv_cmd(tool)
  return function(dispatchers, config)
    local cmd = tool
    if config.root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, ".venv", "bin", tool)
      if vim.fn.executable(local_cmd) == 1 then cmd = local_cmd end
    end
    -- What Neovim passes when cmd is a list, which a function cmd replaces
    return vim.lsp.rpc.start({ cmd, "server" }, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end
end

---@type Toolchain
return {
  servers = {
    ruff = { cmd = venv_cmd("ruff"), executable = "ruff" },
    ty = {
      cmd = venv_cmd("ty"),
      executable = "ty",
      -- Neovim doesn't offer file watching to servers on Linux (see
      -- make_client_capabilities in vim/lsp/protocol.lua), so ty warns it may
      -- show stale results when files change outside the editor (e.g. packages
      -- added by `uv sync`). Offer it again, as for roslyn_ls (see dotnet.lua).
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    },
  },
}
