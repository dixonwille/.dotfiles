-- Bicep: Bicep.LangServer. Formatting and linting come from
-- the server; lint rules live in each repository's bicepconfig.json.
---@type Language
return {
  servers = {
    -- nvim-lspconfig leaves bicep's cmd unset; this is the binary in nixpkgs' bicep
    bicep = { cmd = { "Bicep.LangServer" } },
  },
}
