{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.base._1password;
in {
  options.profiles.base._1password = {
    enable = mkEnableOption "Enable 1Password integrations";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      _1password
    ];
  };
}
