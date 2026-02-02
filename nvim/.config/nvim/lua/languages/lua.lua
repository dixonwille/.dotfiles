-- TODO (wd): include treesitter
-- TODO (wd): include mason
--
---Configure the LuaLS
---@param client vim.lsp.Client
---@param remove_config boolean?
local function configure_nvim_lua_ls(client, remove_config)
  local lib = vim.api.nvim_get_runtime_file("", true)
  if remove_config then
    lib = vim.tbl_filter(function(d)
      return d ~= vim.fn.stdpath("config")
    end, lib)
  end
  lib[#lib + 1] = "${3rd}/luv/library"
  ---@diagnostic disable-next-line: param-type-mismatch
  client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
    runtime = {
      version = "LuaJIT",
      path = { "lua/?.lua", "lua/?/init.lua" }
    },
    workspace = {
      checkThirdParty = false,
      library = lib,
    },
  })
end

vim.lsp.config("lua_ls", {
  ---@type fun(client: vim.lsp.Client)
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path == vim.fn.stdpath("config") or path == vim.fs.joinpath(vim.fn.expand("$HOME"), ".dotfiles", "nvim", ".config", "nvim") then
        configure_nvim_lua_ls(client, true)
      end
    end
  end,
  ---@type fun(client: vim.lsp.Client, bufnr: integer)
  on_attach = function(client, bufnr)
    ---@diagnostic disable-next-line: undefined-field
    if not client.config.settings.Lua.workspace then
      local filename = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
      if filename == ".nvim.lua" then
        configure_nvim_lua_ls(client, false)
      end
    end
  end,
  settings = {
    Lua = {},
  },
})

vim.lsp.enable({ "lua_ls" })
