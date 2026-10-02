-- Vue (vue toolchain): vue_ls handles templates and styles, and hands <script>
-- (TypeScript or JavaScript) to typescript's vtsls, which needs Vue's TypeScript
-- plugin and the vue filetype. The vue toolchain points VUE_TYPESCRIPT_PLUGIN at
-- the plugin that matches its vue_ls.

local plugin = vim.env.VUE_TYPESCRIPT_PLUGIN

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

---@type Toolchain
return { servers = servers }
