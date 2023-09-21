{ config, pkgs, lib, ... }:
{
  imports = [
    ../base
    ../neovim
  ];
  config = {
    profiles.base = {
      username = "wdixon";
      machine = "hmdesk";
      _1password.enable = true;
      git = {
        email = "will@willd.io";
        signing.enable = true;
      };
      wsl = {
        enable = true;
        windows.username = "wdixon";
      };
    };
  };
}
