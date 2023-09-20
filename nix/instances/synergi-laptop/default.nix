{ config, pkgs, lib, ... }:
{
  imports = [
    ../../base
    ../../neovim
    ./az-ssh.nix
    ./dotnet.nix
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
      extraPackages = with pkgs; [
        powershell
        azure-cli
        go
        nodejs_18
        azure-functions-core-tools
      ];
    };
  };
}
