-- Vue: vue_ls handles templates and styles, and hands <script> (TypeScript or
-- JavaScript) to typescript's vtsls, which needs Vue's TypeScript plugin and the
-- vue filetype. The plugin comes with vue_ls (@vue/language-server), so vtsls
-- loads it from the package the vue-language-server on PATH belongs to, and
-- their versions always match.

---The @vue/language-server package directory, from its executable
---@return string?
local function language_server_package()
  local exe = vim.fn.exepath("vue-language-server")
  local real = exe ~= "" and vim.uv.fs_realpath(exe) or nil
  return real and vim.fs.root(real, "package.json") or nil
end

local plugin = language_server_package()

---@type table<string, LanguageServer>
local servers = { vue_ls = {} }

if plugin then
  servers.vtsls = {
    filetypes = vim.list_extend(vim.deepcopy(vim.lsp.config.vtsls.filetypes or {}), { "vue" }),
    settings = {
      vtsls = {
        tsserver = {
          globalPlugins = {
            {
              name = "@vue/typescript-plugin",
              location = plugin,
              languages = { "vue" },
              configNamespace = "typescript",
            },
          },
        },
      },
    },
  }
end

---@type Language
return { servers = servers }
