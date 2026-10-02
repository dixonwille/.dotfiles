-- Go templates (text/template) that render another language, like
-- config.js.tmpl or nginx configs. They get the gotmpl filetype, and the text
-- around {{ }} is highlighted as the language they render (see
-- queries/gotmpl/injections.scm).
--
-- Only files listed in DOTFILES_GOTMPL are Go templates, since other template
-- engines use the same extensions. It's set machine-wide in zsh's env.d and
-- extended per project in .envrc, as space-separated entries:
--   glob           template files, e.g. config.js.tmpl or layouts/**/*.html
--   glob=language  also the rendered language, e.g. nginx.headers.tmpl=nginx
-- Globs match the end of a file's path, so *.conf.tmpl matches in any directory.
-- Without a language, it's detected from the path minus .tmpl/.gotmpl:
-- config.js.tmpl renders JavaScript, nginx/status.conf.tmpl renders nginx.
-- vim.b.gotmpl_lang overrides the language for one buffer.

---@class Template
---@field glob vim.lpeg.Pattern
---@field lang? string

---@type Template[]
local templates = {}
for entry in (vim.env.DOTFILES_GOTMPL or ""):gmatch("%S+") do
  local glob, lang = entry:match("^([^=]+)=?(.*)$")
  table.insert(templates, {
    glob = vim.glob.to_lpeg(vim.startswith(glob, "/") and glob or "**/" .. glob),
    lang = lang ~= "" and lang or nil,
  })
end

---Whether a path is a template, and the language set for it (the last match's)
---@param path string
---@return boolean, string?
local function find(path)
  local found, lang = false, nil
  for _, t in ipairs(templates) do
    if t.glob:match(path) then
      found, lang = true, t.lang or lang
    end
  end
  return found, lang
end

-- Set while detecting a template's rendered language, so a template's own
-- filetype rule doesn't answer for it
local detecting = false

vim.filetype.add({
  pattern = {
    -- Ahead of the extension rules (*.tmpl is "template", *.html is "html")
    [".*"] = {
      function(path)
        if not detecting and find(vim.fs.normalize(path)) then return "gotmpl" end
      end,
      { priority = 1000 },
    },
  },
})

---The treesitter language a template renders, if one can be found
---@param path string
---@return string?
local function rendered_lang(path)
  local _, lang = find(path)
  if lang then return lang end
  detecting = true
  local ok, ft = pcall(vim.filetype.match, { filename = (path:gsub("%.tmpl$", ""):gsub("%.gotmpl$", "")) })
  detecting = false
  return ok and ft and vim.treesitter.language.get_lang(ft) or nil
end

-- Rendered language per buffer, by buffer name. The directive runs for every
-- text node in a template, so detection only runs when the name changes.
---@type table<integer, { name: string, lang: string|false }>
local cache = {}

vim.treesitter.query.add_directive("set-gotmpl-lang!", function(_, _, source, _, metadata)
  if type(source) ~= "number" then return end
  local lang = vim.b[source].gotmpl_lang
  if not lang then
    local name = vim.fs.normalize(vim.api.nvim_buf_get_name(source))
    if not cache[source] or cache[source].name ~= name then
      cache[source] = { name = name, lang = rendered_lang(name) or false }
    end
    lang = cache[source].lang
  end
  if lang then metadata["injection.language"] = lang end
end, { force = true })

vim.api.nvim_create_autocmd("BufWipeout", {
  desc = "Forget a template's rendered language",
  group = vim.api.nvim_create_augroup("Gotmpl", { clear = true }),
  callback = function(ev) cache[ev.buf] = nil end,
})
