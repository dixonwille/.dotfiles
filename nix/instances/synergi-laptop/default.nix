{ config, pkgs, lib, ... }:
{
  imports = [
    ../../base
    ../../neovim
    ../../onepassword
    ./az-ssh.nix
    ./dotnet.nix
    ./npm.nix
  ];
  config = {
    dixonwille = {
      onepassword = {
        enable = true;
        accounts = {
          my = {
            email = "dixonwille@gmail.com";
          };
          sy = {
            address = "synergipartners.1password.com";
            email = "wdixon@synergipartners.com";
          };
        };
      };
    };
    profiles.base = {
      username = "wdixon";
      machine = "splap";
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
    home.packages = with pkgs; [
      powershell
      azure-cli
      go
      azure-functions-core-tools
    ];
    home.sessionVariables = {
      AZURE_CONFIG_DIR = "${config.xdg.dataHome}/azure";
      AZURE_DEVOPS_CACHE_DIR = "${config.xdg.cacheHome}/azure-devops";
      SY_PROJECTS_DIR = "${config.home.homeDirectory}/projects/synergi";
      SY_DOCUMENTATION_REPOSITORY = "$SY_PROJECTS_DIR/Documentation";
    };
  };
}
