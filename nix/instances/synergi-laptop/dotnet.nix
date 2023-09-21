attrs@{ config, pkgs, lib, ... }:

with lib;

let 
  cfg = config.profiles.synergi-laptop.dotnet;
  sdk_5_0 = (import ./derivations/dotnet-sdk-5-0.nix attrs);
  sdk_3_1 = (import ./derivations/dotnet-sdk-3-1.nix attrs);
in {
  options.profiles.synergi-laptop.dotnet = {};
  imports = [
    ./derivations/az-cred-provider.nix
  ];
  config = {
    home.packages = with pkgs; [
      (dotnetCorePackages.combinePackages [
        dotnetCorePackages.sdk_7_0
        dotnetCorePackages.sdk_6_0
        sdk_5_0
        sdk_3_1
      ])
    ];
    home.sessionVariables = {
      NUGET_PACKAGES = "${config.xdg.cacheHome}/NuGetPackages";
      OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
    };
  };
} 
