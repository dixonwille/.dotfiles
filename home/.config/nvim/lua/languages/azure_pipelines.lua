-- Azure Pipelines: files named azure*.yml/azure*.yaml, plus any listed in
-- DOTFILES_AZURE_PIPELINES (set in ~/.config/environment.d, work's in
-- personal/work: ":"-separated globs matching the end of a file's
-- path, e.g.
-- "ci/templates/**/*.yml"), get the yaml.azure-pipelines filetype.
-- Only those get the Azure Pipelines server, validating against the public
-- pipeline schema pinned below. The yaml part keeps treesitter and other YAML
-- tooling working.

local globs = {}
for glob in (vim.env.DOTFILES_AZURE_PIPELINES or ""):gmatch("[^%s:]+") do
  table.insert(globs, vim.glob.to_lpeg(vim.startswith(glob, "/") and glob or "**/" .. glob))
end

-- The public pipeline schema at a commit of microsoft/azure-pipelines-vscode,
-- which the server fetches itself
local schema =
  "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/9e40e814abd20917f273dd587497086f0476a563/service-schema.json"

---@type Language
return {
  filetype = {
    -- Both ahead of the extension rule (*.yml is "yaml"). The azure* names are a
    -- plain mapping, which also makes the filetype known to :checkhealth vim.lsp
    -- (it can't see what a function returns).
    pattern = {
      ["azure.*%.ya?ml"] = { "yaml.azure-pipelines", { priority = 1000 } },
      [".*%.ya?ml"] = {
        function(path)
          path = vim.fs.normalize(path)
          for _, glob in ipairs(globs) do
            if glob:match(path) then return "yaml.azure-pipelines" end
          end
        end,
        { priority = 1000 },
      },
    },
  },
  servers = {
    azure_pipelines_ls = {
      filetypes = { "yaml.azure-pipelines" },
      settings = {
        yaml = { schemas = { [schema] = { "**/*.yml", "**/*.yaml" } } },
      },
    },
  },
}
