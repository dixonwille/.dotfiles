{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/base
  ];
  config = {
    dixonwille = {
      neovim.enable = true;
      onepassword = {
        enable = true;
        accounts = {
          my = {
            email = "dixonwille@gmail.com";
          };
        };
      };
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
  };
}
