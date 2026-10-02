-- Azure Pipelines (azure-pipelines toolchain): files named azure*.yml/azure*.yaml,
-- plus any listed in DOTFILES_AZURE_PIPELINES (set in a project's .envrc:
-- space-separated globs matching the end of a file's path, e.g.
-- "AzDevOps-Pipeline-Templates/**/*.yml"), get the yaml.azure-pipelines filetype.
-- Only those get the Azure Pipelines server, validating against the schema the
-- toolchain pins. The yaml part keeps treesitter and other YAML tooling working.

local globs = {}
for glob in (vim.env.DOTFILES_AZURE_PIPELINES or ""):gmatch("%S+") do
  table.insert(globs, vim.glob.to_lpeg(vim.startswith(glob, "/") and glob or "**/" .. glob))
end

local schema = vim.env.AZURE_PIPELINES_SCHEMA

---@type Toolchain
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
      settings = schema and {
        yaml = { schemas = { [schema] = { "**/*.yml", "**/*.yaml" } } },
      } or nil,
    },
  },
}
