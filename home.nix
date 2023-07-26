{ config, pkgs, ... }:

{
  xdg.enable = true;
  nix.settings.use-xdg-base-directories = true;
  nix.package = pkgs.nix;

  home.username = "wdixon";
  home.homeDirectory = "/home/wdixon";
  home.stateVersion = "23.05"; # Please read the comment before changing.
  home.packages = with pkgs; [
    (python311.withPackages(ps: with ps; [ pip ]))
    cargo
    curl
    fd
    gawk
    gcc
    gnumake
    gnutar
    go
    gzip
    lua54Packages.luarocks
    nodejs_18
    ruby
    tree-sitter
    unzip
    wget
    wl-clipboard
    wslu
  ];
  home.sessionVariables = {
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    ZELLIJ_AUTO_EXIT = "true";
  };
  home.shellAliases = {
    vim = "nvim";
    cat = "bat";
  };
  xdg.configFile = {
    nvim = {
      enable = true;
      recursive= false;
      source = ./dotfiles/nvim;
      target = "nvim";
    };
    ripgrep = {
      enable = true;
      recursive = false;
      text = "";
      target = "ripgrep/ripgreprc";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.git = {
    enable = true;
    userEmail = "will@willd.io";
    userName = "Will Dixon";
    delta.enable = true;
    extraConfig = {
      core = {
        autocrlf = "input";
      };
      pull.rebase = true;
    };
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
        "belak/zsh-utils path:completion"
        "ohmyzsh/ohmyzsh path:plugins/git"
        "ohmyzsh/ohmyzsh path:plugins/npm"
        "ohmyzsh/ohmyzsh path:plugins/dotnet"
        "ohmyzsh/ohmyzsh path:plugins/docker"
        "ohmyzsh/ohmyzsh path:plugins/kubectl"
        "ohmyzsh/ohmyzsh path:plugins/azure"
        "ohmyzsh/ohmyzsh path:plugins/zoxide"
        "ohmyzsh/ohmyzsh path:plugins/ripgrep kind:fpath"
        "ohmyzsh/ohmyzsh path:plugins/fd kind:fpath"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
        "zsh-users/zsh-syntax-highlighting"
      ];
    };
  };
}
