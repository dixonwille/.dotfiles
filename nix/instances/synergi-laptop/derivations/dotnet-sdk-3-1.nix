{ stdenv, fetchurl, ... }:

let
  pname ="dotnet-sdk";
  version = "3.1.426";
in 
stdenv.mkDerivation {
  inherit version pname;
  src = fetchurl {
    url = "https://download.visualstudio.microsoft.com/download/pr/e89c4f00-5cbb-4810-897d-f5300165ee60/027ace0fdcfb834ae0a13469f0b1a4c8/${pname}-${version}-linux-x64.tar.gz";
    hash = "sha256-zOSBwFTDMa1X4m5dMmmTsiCaYbTfZhGOe66HjQn1HcE=";
  };
  sourceRoot = ".";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r * $out/.
  '';
}

