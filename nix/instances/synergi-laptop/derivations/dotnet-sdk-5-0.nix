{ stdenv, fetchurl, ... }:

let
  pname ="dotnet-sdk";
  version = "5.0.408";
in 
stdenv.mkDerivation {
  inherit version pname;
  src = fetchurl {
    url = "https://download.visualstudio.microsoft.com/download/pr/904da7d0-ff02-49db-bd6b-5ea615cbdfc5/966690e36643662dcc65e3ca2423041e/${pname}-${version}-linux-x64.tar.gz";
    hash = "sha256-cZbUm6UDdwCJYS+3ZNdV9x6QG6gr+znoA0fp+4u4bl4=";
  };
  sourceRoot = ".";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r * $out/.
  '';
}

