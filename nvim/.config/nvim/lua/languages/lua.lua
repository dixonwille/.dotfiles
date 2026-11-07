-- Lua: lua-language-server, stylua and selene. Projects describe
-- their libraries in .luarc.json, formatting in .stylua.toml, lints in selene.toml.
---@type Language
return {
  servers = { lua_ls = {} },
  formatters_by_ft = { lua = { "stylua" } },
  linters_by_ft = { lua = { "selene" } },
  lint_roots = { selene = { "selene.toml" } },
}
