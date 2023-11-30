{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/base
  ];
  config = {
    dixonwille = {
      neovim.enable = true;
      onepassword.enable = true;
      base = {
        username = "wdixon";
        machine = "hmdesk";
        git = {
          email = "will@willd.io";
          signing.enable = true;
        };
      };
      wsl = {
        enable = true;
        windows.username = "wdixon";
      };
    };
    home.packages = with pkgs; [
      terraform
    ];
  };
}
