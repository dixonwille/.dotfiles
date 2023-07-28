
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.wsl;
in {
  options.profiles.wsl = {
  };
  config = {
    home.packages = with pkgs; [
      wl-clipboard
      wslu
    ];
  };
}
