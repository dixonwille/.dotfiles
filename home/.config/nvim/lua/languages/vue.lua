-- Vue: vue_ls handles templates and styles, and hands <script> (TypeScript or
-- JavaScript) to typescript's vtsls, which needs Vue's TypeScript plugin and the
-- vue filetype. The plugin comes with vue_ls (@vue/language-server), so vtsls
-- loads it from the package the vue-language-server on PATH belongs to, and
-- their versions always match.

---The @vue/language-server package directory, from its executable (a real
---path: lua/mise.lua swaps mise's shims for the project's tool directories).
---mise installs npm tools with aube, whose bin is a shell script, not a link
---into the package, so its root is the install's; the package is linked under
---that root's node_modules, and its own node_modules has the plugin beside it.
---@return string?
local function language_server_package()
  local exe = vim.fn.exepath("vue-language-server")
  local real = exe ~= "" and vim.uv.fs_realpath(exe) or nil
  local root = real and vim.fs.root(real, "package.json")
  return root and (vim.uv.fs_realpath(vim.fs.joinpath(root, "node_modules", "@vue", "language-server")) or root)
end

local plugin = language_server_package()

---@type table<string, LanguageServer>
local servers = {
  vue_ls = {
    executable = "vue-language-server",
    -- vue_ls takes `typescript` as a peer of any version, so a fresh install
    -- gets the latest, and TypeScript 7 (the native compiler) has no JS API:
    -- every .vue file fails with "Cannot read properties of undefined (reading
    -- 'protocol')" (vuejs/language-tools#6201). Use the project's TypeScript.
    cmd = function(dispatchers, config)
      local cmd = { "vue-language-server", "--stdio" }
      local tsdk = config.root_dir and vim.fs.joinpath(config.root_dir, "node_modules", "typescript", "lib")
      if tsdk and vim.uv.fs_stat(tsdk) then table.insert(cmd, "--tsdk=" .. tsdk) end
      return vim.lsp.rpc.start(cmd, dispatchers, { cwd = config.root_dir })
    end,
  },
}

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
