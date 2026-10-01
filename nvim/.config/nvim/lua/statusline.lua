-- Statusline in the style of mini.statusline, built on Neovim's own pieces
-- (vim.diagnostic.count, vim.lsp.get_clients) with icons from mini.icons.
-- Colors come from standard highlight groups so any colorscheme works.

local M = {}

local CTRL_V = vim.keycode("<C-v>")
local CTRL_S = vim.keycode("<C-s>")

---@type table<string, { label: string, hl: string }>
local modes = {
  n = { label = "NORMAL", hl = "Normal" },
  v = { label = "VISUAL", hl = "Visual" },
  V = { label = "V-LINE", hl = "Visual" },
  [CTRL_V] = { label = "V-BLOCK", hl = "Visual" },
  s = { label = "SELECT", hl = "Visual" },
  S = { label = "S-LINE", hl = "Visual" },
  [CTRL_S] = { label = "S-BLOCK", hl = "Visual" },
  i = { label = "INSERT", hl = "Insert" },
  R = { label = "REPLACE", hl = "Replace" },
  c = { label = "COMMAND", hl = "Command" },
  r = { label = "PROMPT", hl = "Other" },
  ["!"] = { label = "SHELL", hl = "Other" },
  t = { label = "TERMINAL", hl = "Other" },
}

-- Mode block background comes from the foreground of these standard groups
local mode_colors = {
  Normal = "Function",
  Insert = "String",
  Visual = "Keyword",
  Replace = "DiagnosticError",
  Command = "Constant",
  Other = "Type",
}

local severities = {
  { vim.diagnostic.severity.ERROR, "󰅚", "DiagnosticError" },
  { vim.diagnostic.severity.WARN, "󰀪", "DiagnosticWarn" },
  { vim.diagnostic.severity.INFO, "󰋽", "DiagnosticInfo" },
  { vim.diagnostic.severity.HINT, "󰌶", "DiagnosticHint" },
}

local function set_highlights()
  local base = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }).bg
    or vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
  for name, source in pairs(mode_colors) do
    local color = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
    -- Transparent themes have no background to use as text color, so invert
    local hl = base and { fg = base, bg = color, bold = true } or { fg = color, reverse = true, bold = true }
    hl.default = true
    vim.api.nvim_set_hl(0, "StatusLineMode" .. name, hl)
  end
end

---@param category string
---@param name string
---@return string
local function icon(category, name)
  local ok, icons = pcall(require, "mini.icons")
  if not ok or name == "" then return "" end
  local glyph = icons.get(category, name)
  return glyph .. " "
end

---@return string
local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local parts = {}
  for _, s in ipairs(severities) do
    local n = counts[s[1]]
    if n then table.insert(parts, ("%%#%s#%s %d"):format(s[3], s[2], n)) end
  end
  return #parts > 0 and table.concat(parts, " ") .. "%#StatusLine#" or ""
end

---@return string
local function lsp()
  local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
  return #names > 0 and "󰰎 " .. table.concat(names, " ") or ""
end

---@param wide boolean
---@return string
local function fileinfo(wide)
  local ft = vim.bo.filetype
  local info = ft ~= "" and icon("filetype", ft) .. ft or ""
  if not wide or vim.bo.buftype ~= "" then return info end
  local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
  return ("%s %s[%s]"):format(info, encoding, vim.bo.fileformat)
end

---Join non-empty sections with a space
---@param sections string[]
---@return string
local function join(sections)
  return table.concat(vim.tbl_filter(function(s) return s ~= "" end, sections), "  ")
end

---Rendered for each window via %{%...%}, with that window's buffer as current
---@return string
function M.render()
  local name = vim.fn.expand("%:t")
  local file = icon("file", name) .. "%f%( %m%r%)"
  if vim.api.nvim_get_current_win() ~= tonumber(vim.g.actual_curwin) then return "%#StatusLineNC# " .. file .. "%=" end

  local mode = modes[vim.api.nvim_get_mode().mode:sub(1, 1)] or { label = "UNKNOWN", hl = "Other" }
  local mode_hl = "%#StatusLineMode" .. mode.hl .. "#"
  local wide = vim.api.nvim_win_get_width(0) >= 120

  return table.concat({
    mode_hl,
    " " .. mode.label .. " ",
    "%#StatusLine# ",
    join({ diagnostics(), lsp() }),
    "  %<",
    file,
    "%=",
    fileinfo(wide),
    " ",
    mode_hl,
    " %l:%v %P ",
  })
end

set_highlights()

local aug = vim.api.nvim_create_augroup("Statusline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Recompute statusline mode colors",
  group = aug,
  callback = set_highlights,
})
vim.api.nvim_create_autocmd({ "ModeChanged", "LspAttach", "LspDetach" }, {
  desc = "Refresh statusline",
  group = aug,
  callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
})

vim.o.statusline = "%{%v:lua.require'statusline'.render()%}"

return M
