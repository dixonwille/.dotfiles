{ pkgs, ... }:

let
  pname = "Microsoft.Net6.NuGet.CredentialProvider";
  version = "1.0.9";
  pluginDir = "plugins/netcore/CredentialProvider.Microsoft";
  der = pkgs.stdenv.mkDerivation {
    inherit version pname;
    src = pkgs.fetchurl {
      url = "https://github.com/microsoft/artifacts-credprovider/releases/download/v${version}/${pname}.tar.gz";
      hash = "sha256-7SNpqz/0c1RZ1G0we68ZGd2ucrsKFBp7fAD/7j7n9Bc=";
    };
    sourceRoot = pluginDir;
    dontBuild = true;
    buildInputs = [ pkgs.dotnet-sdk ];
    installPhase = ''
      mkdir -p $out
      cp -r * $out/.
    '';
  };
in {
  config.home.file = {
    ".nuget/${pluginDir}" = {
      enable = true;
      source = der;
    };
  };
}

