{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.neovim;
in {
  options.profiles.neovim = {};
  config = {
    home.packages = with pkgs; [
      (python311.withPackages(ps: with ps; [ pip ]))
      cargo
      curl
      gcc
      gnumake
      go
      lua54Packages.luarocks
      nodejs_18
      ruby
      tree-sitter
      wget
    ];
    home.shellAliases = {
      vim = "nvim";
    };
    xdg.configFile = {
      nvim = {
        enable = true;
        recursive= false;
        source = ./rc;
        target = "nvim";
      };
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
