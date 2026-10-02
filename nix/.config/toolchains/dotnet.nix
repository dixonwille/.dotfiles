# .NET SDKs and the Roslyn language server. Unlike other runtimes this isn't
# versioned per toolchain: .NET selects its own SDK from a repository's
# global.json, so every SDK in use lives in this one environment (add new ones,
# drop retired ones). They have to be combined into a single `dotnet` to sit
# side by side, and the language server needs the .NET 10 runtime anyway.
{ pkgs }:
let
  # Newest first: combinePackages takes the `dotnet` host from the first SDK
  dotnet =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_10_0
      sdk_8_0
    ];
in
{
  packages = [
    dotnet
    pkgs.roslyn-ls
  ];
  env = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
    # Azure Artifacts credential provider, so restores can authenticate to
    # Azure DevOps feeds. Replaces NuGet's search of ~/.nuget/plugins; the
    # sign-in cache it shares with a global install is in ~/.local/share.
    NUGET_PLUGIN_PATHS = "${pkgs.azure-artifacts-credprovider}/lib/azure-artifacts-credprovider/CredentialProvider.Microsoft.dll";
  };
}
