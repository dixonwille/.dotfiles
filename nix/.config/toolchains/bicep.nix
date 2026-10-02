# Bicep CLI and language server (Bicep.LangServer). Formatting and linting
# come from the language server; lint rules live in each repo's
# bicepconfig.json. Not nixpkgs' bicep-lsp, which lags far behind.
{ pkgs }:
{
  packages = [ pkgs.bicep ];
  # az deploys .bicep files with this bicep rather than downloading its own
  # (az reads config from AZURE_<SECTION>_<NAME> variables)
  env.AZURE_BICEP_USE_BINARY_FROM_PATH = "true";
}
