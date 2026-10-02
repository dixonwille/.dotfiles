# PowerShell Editor Services (the VS Code PowerShell extension's server, with
# PSScriptAnalyzer). It runs in nixpkgs' PowerShell, so it doesn't depend on
# the globally installed pwsh, which stays the one on PATH for running scripts.
{ pkgs }:
{
  packages = [ pkgs.powershell-editor-services ];
  # Read by lua/toolchains/powershell.lua (nvim-lspconfig's bundle_path and shell)
  env = {
    PSES_BUNDLE_PATH = "${pkgs.powershell-editor-services}/lib/powershell-editor-services";
    PSES_PWSH = "${pkgs.powershell}/bin/pwsh";
  };
}
