{ config, pkgs, lib, ... }:
{
  imports = [
    ../base
    ../neovim
    ../wsl.nix
  ];
  config = {
    profiles.base = {
      username = "wdixon";
      gitEmail = "will@willd.io";
    };
    profiles.wsl._1passwordAgent.enable = true;
    
  };
}
