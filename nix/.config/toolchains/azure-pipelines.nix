# Azure Pipelines: Microsoft's language server (not in nixpkgs; packaged from
# pkgs/azure-pipelines-language-server) and the public pipeline schema it
# validates against, pinned to a commit of microsoft/azure-pipelines-vscode.
# lua/toolchains/azure_pipelines.lua decides which files are pipelines.
{ pkgs }:
{
  packages = [
    (import ./pkgs/npm-server.nix {
      inherit pkgs;
      package = "azure-pipelines-language-server";
      bin = "azure-pipelines-language-server";
      src = ./pkgs/npm-server/azure-pipelines-language-server;
    })
  ];
  env.AZURE_PIPELINES_SCHEMA = pkgs.fetchurl {
    name = "azure-pipelines-service-schema.json";
    url = "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/9e40e814abd20917f273dd587497086f0476a563/service-schema.json";
    hash = "sha256-8AqWMPZVAgQUhjTZoT9jS1dQoiVVmIbv/gmnUUgvBFk=";
  };
}
