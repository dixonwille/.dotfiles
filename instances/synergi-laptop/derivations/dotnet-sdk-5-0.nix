{ pkgs, lib, ... }:

let
  pname ="dotnet-sdk";
  version = "5.0.408";
in 
pkgs.stdenv.mkDerivation {
  inherit version pname;
  src = pkgs.fetchurl {
    url = "https://download.visualstudio.microsoft.com/download/pr/904da7d0-ff02-49db-bd6b-5ea615cbdfc5/966690e36643662dcc65e3ca2423041e/${pname}-${version}-linux-x64.tar.gz";
    hash = "sha256-cZbUm6UDdwCJYS+3ZNdV9x6QG6gr+znoA0fp+4u4bl4=";
  };
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ] ++ lib.optional stdenv.isLinux autoPatchelfHook;

  buildInputs = with pkgs; [
    stdenv.cc.cc
    zlib
    icu
    libkrb5
    curl
  ] ++ lib.optional stdenv.isLinux lttng-ust_2_12;

  sourceRoot = ".";
  dontPatchELF = true;
  noDumpEnvVars = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r ./ $out

    mkdir -p $out/share/doc/$pname/$version
    mv $out/LICENSE.txt $out/share/doc/$pname/$version/
    mv $out/ThirdPartyNotices.txt $out/share/doc/$pname/$version/

    ln -s $out/dotnet $out/bin/dotnet

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/dotnet --info
  '';
  postFixup = lib.optionalString pkgs.stdenv.isLinux ''
    patchelf \
      --add-needed libicui18n.so \
      --add-needed libicuuc.so \
      $out/shared/Microsoft.NETCore.App/*/libcoreclr.so \
      $out/shared/Microsoft.NETCore.App/*/*System.Globalization.Native.so \
      $out/packs/Microsoft.NETCore.App.Host.linux-x64/*/runtimes/linux-x64/native/singlefilehost
    patchelf \
      --add-needed libgssapi_krb5.so \
      $out/shared/Microsoft.NETCore.App/*/*System.Net.Security.Native.so \
      $out/packs/Microsoft.NETCore.App.Host.linux-x64/*/runtimes/linux-x64/native/singlefilehost
    patchelf \
      --add-needed libssl.so \
      $out/shared/Microsoft.NETCore.App/*/*System.Security.Cryptography.Native.OpenSsl.so \
      $out/packs/Microsoft.NETCore.App.Host.linux-x64/*/runtimes/linux-x64/native/singlefilehost
  '';
  setupHook = pkgs.writeText "dotnet-setup-hook" ''
    if [ ! -w "$HOME" ]; then
      export HOME=$(mktemp -d) # Dotnet expects a writable home directory for its configuration files
    fi

    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 # Dont try to expand NuGetFallbackFolder to disk
    export DOTNET_NOLOGO=1 # Disables the welcome message
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
  '';
}

