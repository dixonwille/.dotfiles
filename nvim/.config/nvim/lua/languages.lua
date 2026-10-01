local linter = require("lint")
linter.linters_by_ft = {
  lua = { "selene" },
}

-- Linters that only read their config from the working directory, mapped to
-- the files that mark that directory
local lint_roots = {
  selene = { "selene.toml" },
}

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
        local markers = lint_roots[name]
        linter.try_lint(name, { cwd = markers and vim.fs.root(opt.buf, markers) or nil })
      end
    end
  end,
})

-- Formatters come from the project environment; missing ones are skipped
-- quietly and LSP formatting is used instead
require("conform").setup({
  notify_no_formatters = false,
  formatters_by_ft = {
    lua = { "stylua" },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
})

---Enable language servers whose command is on PATH. Servers come from the
---project environment (see ~/.config/toolchains), not from Neovim.
---@param names string[]
local function enable_available(names)
  for _, name in ipairs(names) do
    local cmd = vim.lsp.config[name].cmd
    -- A function cmd can't be checked ahead of time, so trust it
    if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then vim.lsp.enable(name) end
  end
end

enable_available({ "lua_ls" })

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
