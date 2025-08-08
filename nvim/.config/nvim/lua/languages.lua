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
nvimts.install({ "c", "lua", "markdown", "markdown_inline", "query", "vim", "vimdoc", "comment" })

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
      if path == vim.fn.stdpath("config") then
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

vim.lsp.config("bicep", {
  cmd = { "bicep-lsp" },
})

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

vim.lsp.enable({ "lua_ls" })

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
