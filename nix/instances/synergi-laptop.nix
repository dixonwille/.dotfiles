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
      gitEmail = "wdixon@synergipartners.com";
    };
    
  };
}
