{ config, pkgs, lib, ... }:
{
  imports = [
    ../../base
    ../../neovim
    ./azssh.nix
  ];
  config = {
    profiles.base = {
      username = "wdixon";
      _1password.enable = true;
      git = {
        email = "wdixon@synergipartners.com";
        signing.enable = true;
        signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1eoaIykCQPVIoA4B36RRNthzqcxBMjVVaQLLK8Xks2";
      };
      wsl = {
        enable = true;
        windows.username = "wdixon";
      };
    };
  };
}
