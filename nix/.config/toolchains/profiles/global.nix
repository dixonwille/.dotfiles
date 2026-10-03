# Command-line tools for every machine. Each set in profiles/ goes in the user's
# nix profile, ahead of the system's packages, and a machine's install script
# adds the sets it uses:
#   nix profile add "path:$(realpath ~/.config/toolchains)#global" ...#work
# To upgrade, run `nix flake update` in ~/.config/toolchains (which moves the
# toolchains too), then `nix profile upgrade --all`.
#
# Left to the system: what bootstraps the dotfiles before nix (git, stow, curl),
# the login shell (zsh), and the C compiler tree-sitter builds parsers with.
{ pkgs }:
pkgs.buildEnv {
  name = "dotfiles-global";
  paths =
    with pkgs;
    [
      # Shell (zsh/.zshrc, tmux, nix)
      direnv
      nix-direnv
      oh-my-posh
      tmux
      fzf # project-cd, tmux-sessionizer, fzf-lua
      eza # ls alias
      bat # cat alias, fzf-lua previews
      tealdeer # tldr

      # Editor (nvim)
      neovim-unwrapped
      tree-sitter # nvim-treesitter builds parsers with it
      ripgrep # fzf-lua grep
      fd # fzf-lua files
      gh # GitHub Actions language server's token and repository

      # Version control (git, jj)
      delta # git pager
      jujutsu

      # Data and scripts
      jq
      yq-go
      sqlite
      uv # uvx for MCP servers; projects get theirs from the python toolchain

      # Network and system
      cloudflared # tunnels on my own Cloudflare account
      htop

      # Agents
      claude-code # Doesn't update itself; moves with `nix flake update`
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      # inotifywait: Neovim's file watching for language servers on Linux (see
      # nvim lua/toolchains/dotnet.lua); without it Neovim falls back to a watcher
      # per directory. Also for scripts that wait on file changes.
      inotify-tools
      wl-clipboard # wl-copy: Neovim's clipboard, gh, rofimoji (WSL through WSLg)
    ];
}
