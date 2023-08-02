{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.base;
in {
  imports = [./wsl.nix];
  options.profiles.base = {
    username = mkOption {
      type = types.str;
      example = "wdixon";
      description = mdDoc "The username for which to setup configuration for.";
    };
    _1password.enable = mkEnableOption "Enable 1Password integrations";
    git = {
      email = mkOption {
        type = types.str;
        example = "will@willd.io";
        description = mdDoc "Email to use for git configuration";
      };
      signing = {
        enable = mkEnableOption "Enable git signing";
        key = mkOption {
          type = types.str;
          description = "Git signing key to use";
          default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRa1dR9AYMJDnKX815Y1M1qw8mh2rSRWxktiadaFJsP";
        };
      };
    };
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of extra packages to install";
    };
  };

  config = {
    xdg.enable = true;
    nix.settings.use-xdg-base-directories = true;
    nix.package = pkgs.nix;
    nixpkgs.config = import ./nixpkgs/config.nix { inherit lib; };

    home.username = cfg.username;
    home.homeDirectory = "/home/${cfg.username}";
    home.stateVersion = "23.05";

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      curl
      fd
      gawk
      gnutar
      gzip
      unzip
    ] ++ cfg.extraPackages;

    home.sessionVariables = {
      LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
      ZELLIJ_AUTO_EXIT = "true";
    };
    home.sessionPath = [
      "$HOME/.local/bin"
    ];
    home.shellAliases = {
      cat = "bat";
      mktmpd = "cd $(mktemp -d)";
      mktmpf = "$EDITOR $(mktemp)";
    };

    xdg.configFile = {
      ripgrep = {
        enable = true;
        recursive = false;
        text = "";
        target = "ripgrep/ripgreprc";
      };
      nixConfig = {
        enable = true;
        recursive = false;
        source = ./nixpkgs/config.nix;
        target = "nixpkgs/config.nix";
      };
    };

    programs.git = {
      enable = true;
      userEmail = cfg.git.email;
      userName = "Will Dixon";
      delta.enable = true;
      signing = mkIf cfg.git.signing.enable {
        key = cfg.git.signing.key;
        signByDefault = true;
      };
      extraConfig = {
        core = {
          ignorecase = false;
          autocrlf = "input";
        };
        pull.rebase = true;
      };
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    programs.bat.enable = true;
    programs.exa = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };
    programs.bottom.enable = true;
    programs.less.enable = true;
    programs.jq.enable = true;
    programs.tealdeer.enable = true;
    programs.oh-my-posh = {
      enable = true;
      useTheme = "atomic";
    };
    programs.ripgrep.enable = true;
    programs.zoxide.enable = true;
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zsh = {
      enable = true;
      enableCompletion = false;
      dotDir = ".config/zsh";
      history.path = "${config.xdg.dataHome}/zsh/zsh_history";
      antidote = {
        enable = true;
        plugins = [
          "ohmyzsh/ohmyzsh path:plugins/git kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/npm kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/dotnet kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/docker kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/kubectl kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/azure kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/zoxide kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/ripgrep kind:fpath"
          "ohmyzsh/ohmyzsh path:plugins/fd kind:fpath"
          "zsh-users/zsh-completions"
          "zsh-users/zsh-autosuggestions"
          "zsh-users/zsh-syntax-highlighting"
          "belak/zsh-utils path:completion"
          "ohmyzsh/ohmyzsh path:lib"
          "ohmyzsh/ohmyzsh path:plugins/git"
          "ohmyzsh/ohmyzsh path:plugins/npm"
          "ohmyzsh/ohmyzsh path:plugins/dotnet"
          "ohmyzsh/ohmyzsh path:plugins/docker"
          "ohmyzsh/ohmyzsh path:plugins/kubectl"
          "ohmyzsh/ohmyzsh path:plugins/azure"
          "ohmyzsh/ohmyzsh path:plugins/zoxide"
        ];
      };
    };
  };
}
