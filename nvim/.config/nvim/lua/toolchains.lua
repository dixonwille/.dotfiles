-- Editor support for toolchains. Each lua/toolchains/<toolchain>.lua module
-- returns a Toolchain spec for the tools that toolchain brings (see
-- ~/.config/toolchains; versioned ones share a module, go1_26 -> go.lua); this
-- file merges every spec and sets up the language servers, formatters and linters.
--
-- Tools come from the project environment, not Neovim, so each is only used
-- when its command is executable: servers are enabled, linters run, and
-- missing formatters are skipped quietly (LSP formatting is the fallback).
--
-- Modules may add to the same thing (vue adds its plugin to typescript's
-- vtsls), but not set the same setting twice: that warns, naming both modules,
-- and the first (alphabetically) keeps it. Order never decides silently.
-- Modules are loaded before anything is applied, so a module reading
-- vim.lsp.config.<server> sees nvim-lspconfig's defaults. A module that fails
-- to load is skipped with a warning, leaving the others working.

---@class Toolchain
---@field servers? table<string, LanguageServer> Servers to enable, with vim.lsp.config overrides ({} for none)
---@field formatters_by_ft? table<string, string[]> conform formatters per filetype
---@field formatters? table<string, table> conform formatter overrides
---@field linters_by_ft? table<string, string[]> nvim-lint linters per filetype
---@field lint_roots? table<string, string[]> Linters reading config only from their cwd: files marking that dir
---@field filetype? vim.filetype.add.filetypes Passed to vim.filetype.add
---@field setup? fun() Anything else (commands, autocmds, query directives)

---@class LanguageServer: vim.lsp.Config
---@field executable? string Command to look for when the server's cmd is a function

---@type table<string, Toolchain>
local toolchains = {}
local names = {} ---@type string[]
for _, file in ipairs(vim.api.nvim_get_runtime_file("lua/toolchains/*.lua", true)) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  if not toolchains[name] then
    local ok, toolchain = pcall(require, "toolchains." .. name)
    if ok then
      names[#names + 1] = name
      toolchains[name] = toolchain
    else
      vim.notify(("toolchains: skipping %s, which failed to load:\n%s"):format(name, toolchain), vim.log.levels.WARN)
    end
  end
end
table.sort(names)

-- Who set each setting, by its path of keys (e.g. servers, vtsls, filetypes),
-- joined with a separator no key contains (keys like "compose%.ya?ml" have dots)
---@type table<string, string>
local owners = {}

---@param path string[]
---@return string?
local function owner_of(path)
  for i = #path, 1, -1 do
    local owner = owners[table.concat(path, "\31", 1, i)]
    if owner then return owner end
  end
end

---Tables of settings, which modules can add to. Empty ones count (e.g. a
---server's `{}` for its defaults), though vim.islist says {} is a list.
---@param value any
---@return boolean
local function is_dict(value) return type(value) == "table" and (next(value) == nil or not vim.islist(value)) end

---Merge a module's settings into the combined ones; a setting already set by
---another module is a conflict
---@param into table
---@param from table
---@param path string[]
---@param module string
local function merge(into, from, path, module)
  for key, value in pairs(from) do
    local p = vim.list_extend(vim.list_slice(path), { tostring(key) })
    if into[key] == nil then
      into[key] = vim.deepcopy(value)
      owners[table.concat(p, "\31")] = module
    elseif is_dict(into[key]) and is_dict(value) then
      merge(into[key], value, p, module)
    else
      local owner = owner_of(p)
      vim.notify(
        ("toolchains: %s and %s both set %s; keeping %s's"):format(owner, module, table.concat(p, "."), owner),
        vim.log.levels.WARN
      )
    end
  end
end

local merged = {
  servers = {}, ---@type table<string, LanguageServer>
  formatters_by_ft = {}, ---@type table<string, string[]>
  formatters = {}, ---@type table<string, table>
  linters_by_ft = {}, ---@type table<string, string[]>
  lint_roots = {}, ---@type table<string, string[]>
  filetype = {}, ---@type vim.filetype.add.filetypes
}
for _, name in ipairs(names) do
  local toolchain = toolchains[name]
  for field, into in pairs(merged) do
    if field == "linters_by_ft" then
      -- Linters don't depend on each other's order, so they just add up
      for ft, linters in pairs(toolchain.linters_by_ft or {}) do
        into[ft] = into[ft] or {}
        for _, l in ipairs(linters) do
          if not vim.list_contains(into[ft], l) then table.insert(into[ft], l) end
        end
      end
    elseif toolchain[field] then
      merge(into, toolchain[field], { field }, name)
    end
  end
end

vim.filetype.add(merged.filetype)
for _, name in ipairs(names) do
  local setup = toolchains[name].setup
  local ok, err = pcall(setup or function() end)
  if not ok then vim.notify(("toolchains: %s's setup failed:\n%s"):format(name, err), vim.log.levels.WARN) end
end

-- Linters ---------------------------------------------------------------------

local linter = require("lint")
linter.linters_by_ft = merged.linters_by_ft

---Linters come from the project environment, so only run ones on PATH
---@param name string
---@return boolean
local function linter_available(name)
  local l = linter.linters[name]
  if type(l) == "function" then l = l() end
  local cmd = l.cmd
  if type(cmd) == "function" then cmd = cmd() end
  return vim.fn.executable(cmd) == 1
end

local aug = vim.api.nvim_create_augroup("Lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  desc = "Lint after save",
  pattern = "*",
  group = aug,
  callback = function(opt)
    for _, name in ipairs(linter.linters_by_ft[vim.bo[opt.buf].filetype] or {}) do
      if linter_available(name) then
        local markers = merged.lint_roots[name]
        linter.try_lint(name, { cwd = markers and vim.fs.root(opt.buf, markers) or nil })
      end
    end
  end,
})

-- Formatters ------------------------------------------------------------------

require("conform").setup({
  notify_no_formatters = false,
  formatters_by_ft = merged.formatters_by_ft,
  formatters = merged.formatters,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
})

-- Language servers ------------------------------------------------------------

for name, server in pairs(merged.servers) do
  local executable = server.executable
  server.executable = nil
  if next(server) then vim.lsp.config(name, server) end
  local cmd = vim.lsp.config[name].cmd
  executable = executable or (type(cmd) == "table" and cmd[1] or nil)
  if executable and vim.fn.executable(executable) == 1 then vim.lsp.enable(name) end
end

-- Show LSP progress as Neovim progress messages (displayed by ui2). See :h LspProgress
vim.api.nvim_create_autocmd("LspProgress", {
  desc = "Show LSP progress as progress messages",
  group = vim.api.nvim_create_augroup("LspProgressMessages", { clear = true }),
  callback = function(ev)
    local params = ev.data.params
    local value = params.value
    vim.api.nvim_echo({ { value.message or "done" } }, false, {
      -- Tokens are only unique per server
      id = ("lsp.%d.%s"):format(ev.data.client_id, params.token),
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})
