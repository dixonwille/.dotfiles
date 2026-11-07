local nvimts = require("nvim-treesitter")

---@type table<string, boolean>?
local available

---Whether nvim-treesitter knows how to install a parser for the language
---@param lang string
---@return boolean
local function is_available(lang)
  if not available then
    available = {}
    for _, l in ipairs(nvimts.get_available()) do
      available[l] = true
    end
  end
  return available[lang] == true
end

---@param lang string
---@return boolean
local function has_parser(lang)
  -- language.add returns nil (not an error) when the parser is missing
  local ok, loaded = pcall(vim.treesitter.language.add, lang)
  return ok and loaded == true
end

---@param fn function
---@param name string
---@return any
local function upvalue(fn, name)
  for i = 1, math.huge do
    local n, v = debug.getupvalue(fn, i)
    if n == nil then return end
    if n == name then return v end
  end
end

---Neovim remembers "no parser for <lang>" for the whole session (the memoized
---has_parser in languagetree.lua), so a parser installed after an injection was
---first seen is ignored until restart. Clear that cache. This reaches into
---private internals; if they change it does nothing and a restart is needed.
local function forget_missing_parsers()
  pcall(function()
    ---@diagnostic disable-next-line: invisible
    local resolve_lang = upvalue(require("vim.treesitter.languagetree")._get_injection, "resolve_lang")
    upvalue(resolve_lang, "has_parser"):clear()
  end)
end

-- Languages already installed (or tried) this session, so failures aren't retried
---@type table<string, boolean>
local attempted = {}

---@param langs string[]
---@param on_done? fun()
local function install(langs, on_done)
  langs = vim.tbl_filter(function(lang) return not has_parser(lang) end, langs)
  for _, lang in ipairs(langs) do
    attempted[lang] = true
  end
  if #langs == 0 then
    if on_done then on_done() end
    return
  end
  nvimts.install(langs):await(vim.schedule_wrap(function()
    if on_done then on_done() end
  end))
end

-- WARN: neovim expects some of these to be installed
install({
  "c",
  "comment",
  "html",
  "latex",
  "lua",
  "markdown",
  "markdown_inline",
  "query",
  "vim",
  "vimdoc",
  "yaml",
})

---Resolve an injection name to a parser name the way Neovim's LanguageTree does,
---except the parser only has to be installable, not installed. Only for
---injections: filetypes resolve differently (see try_enable).
---@param alias string?
---@return string?
local function resolve_lang(alias)
  if not alias then return end
  alias = alias:gsub("%s+", ""):lower():gsub("%-", "_")
  if alias:match("[%w_]+") ~= alias then return end
  if is_available(alias) then return alias end
  local lang = vim.treesitter.language.get_lang(alias)
  if lang and is_available(lang) then return lang end
end

---Language an injection query match asks for (see LanguageTree:_get_injection)
---@param query vim.treesitter.Query
---@param match table<integer, TSNode[]>
---@param metadata vim.treesitter.query.TSMetadata
---@param bufnr integer
---@return string?
local function injection_lang(query, match, metadata, bufnr)
  local lang = resolve_lang(metadata["injection.language"] --[[@as string?]])
  for id, nodes in pairs(match) do
    local name = query.captures[id]
    if name == "injection.language" or name == "injection.filename" then
      local text = vim.treesitter.get_node_text(nodes[1], bufnr, { metadata = metadata[id] })
      if name == "injection.filename" then
        local ft = vim.filetype.match({ filename = text })
        lang = ft and resolve_lang(ft)
      else
        lang = resolve_lang(text)
      end
    end
  end
  return lang
end

---Injected languages in the visible part of a window that have no parser yet
---@param win integer
---@return string[]
local function missing_injections(win)
  local bufnr = vim.api.nvim_win_get_buf(win)
  local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
  if not parser then return {} end

  local top = vim.fn.line("w0", win) - 1
  local bottom = vim.fn.line("w$", win)
  parser:parse({ top, bottom })

  local missing = {} ---@type table<string, boolean>
  parser:for_each_tree(function(tree, ltree)
    local query = vim.treesitter.query.get(ltree:lang(), "injections")
    if not query then return end
    for _, match, metadata in query:iter_matches(tree:root(), bufnr, top, bottom) do
      local lang = injection_lang(query, match, metadata, bufnr)
      if lang and not attempted[lang] and not has_parser(lang) then missing[lang] = true end
    end
  end)
  return vim.tbl_keys(missing)
end

---Install parsers for languages injected into what the window shows, then
---reparse so they highlight. Repeats for languages nested inside those.
---@param win integer
local function install_injections(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  local bufnr = vim.api.nvim_win_get_buf(win)
  if not vim.treesitter.highlighter.active[bufnr] then return end

  local missing = missing_injections(win)
  if #missing == 0 then return end
  install(missing, function()
    forget_missing_parsers()
    local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
    if parser then parser:invalidate(true) end
    install_injections(win)
    vim.cmd.redraw({ bang = true })
  end)
end

---@param bufnr integer
local function enable_ts(bufnr)
  vim.treesitter.start(bufnr)
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.wo.foldlevel = 999
  vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

---Try and enable treesitter, installing the parser for the filetype if needed
---@param bufnr integer
---@param filetype string
local function try_enable(bufnr, filetype)
  -- Same lookup vim.treesitter.start uses, so this installs the parser it loads.
  -- Not resolve_lang: that ignores language.register() and compound filetypes.
  local lang = vim.treesitter.language.get_lang(filetype)
  if not lang then return end
  if has_parser(lang) then
    enable_ts(bufnr)
  elseif is_available(lang) and not attempted[lang] then
    install({ lang }, function()
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      enable_ts(bufnr)
      install_injections(vim.api.nvim_get_current_win())
    end)
  end
end

local aug = vim.api.nvim_create_augroup("TreesitterFT", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "Setup Treesitter for filetypes",
  group = aug,
  callback = function(opt) try_enable(opt.buf, opt.match) end,
})

-- Check once the view settles instead of on every scroll step or keystroke
local timer = assert(vim.uv.new_timer())
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinScrolled", "InsertLeave", "TextChanged" }, {
  desc = "Install parsers for injected languages in view",
  group = aug,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    timer:stop()
    timer:start(200, 0, vim.schedule_wrap(function() install_injections(win) end))
  end,
})
