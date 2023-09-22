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
        machine = "winlap";
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
  };
}
