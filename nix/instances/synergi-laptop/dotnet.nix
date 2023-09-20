
{ config, pkgs, lib, ... }:

with lib;

let 
   cfg = config.profiles.synergi-laptop.dotnet;
   pluginDir = "plugins/netcore/CredentialProvider.Microsoft";
   azCredsProvider = pkgs.stdenv.mkDerivation {
    name = "azure-artifacts-credprovider";
    version = "1.0.9";
    src = pkgs.fetchurl {
      url = "https://github.com/microsoft/artifacts-credprovider/releases/download/v${version}/Microsoft.Net6.NuGet.CredentialProvider.tar.gz";
      hash = "sha256-7SNpqz/0c1RZ1G0we68ZGd2ucrsKFBp7fAD/7j7n9Bc=";
    };
    sourceRoot = pluginDir;
    buildInputs = [ pkgs.dotnet-sdk ];
    installPhase = ''
      mkdir -p $out
      cp -r * $out/.
    '';
   };
in {
  options.profiles.synergi-laptop.dotnet = {};
  config = {
    home.file = {
      ".nuget/${pluginDir}" = {
        enable = true;
        source = azCredsProvider;
      };
    };
  };
}
