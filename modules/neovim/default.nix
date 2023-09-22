{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.dixonwille.neovim;
in {
  options.dixonwille.neovim = {
    enable = mkEnableOption "Enable neovim integrations";
  };
  config = mkIf cfg.enable {
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
    home.sessionVariables = {
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      GOPATH = "${config.xdg.dataHome}/go";
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
