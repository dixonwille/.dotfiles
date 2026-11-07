# Command-line tools for every machine: what I use whatever the project. The
# one set in the user's nix profile, ahead of the system's packages (./install
# adds it):
#   nix profile add "path:$HOME/.dotfiles/profile#global"
# To upgrade, run `nix flake update` in profile/, then `nix profile upgrade --all`.
#
# Not here: a project's tools (runtimes, language servers, formatters, linters).
# Each project declares its own in mise.toml, at the versions its CI uses; on
# work, the runtimes are the workstation's.
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
      mise # each project's tools, from its mise.toml (activated in .zshrc)
      oh-my-posh
      tmux
      fzf # project-cd, tmux-sessionizer, fzf-lua
      eza # ls alias
      bat # cat alias, fzf-lua previews
      tealdeer # tldr
      taskwarrior3

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
      sqlite

      # Services
      codecrafters-cli

      # Network and system
      cloudflared # tunnels on my own Cloudflare account
      htop

      # Agents
      # Doesn't update itself; moves with `nix flake update`. Its wrapper puts
      # alsa-lib (voice input) on LD_LIBRARY_PATH, which every command it runs
      # inherits, so binaries on another glibc (Playwright's Chromium) can fail
      # to start. It can't go in the binary's RUNPATH instead: patchelf breaks
      # the app bundled in its .bun section.
      claude-code
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      # inotifywait: Neovim's file watching for language servers on Linux (see
      # nvim lua/languages/dotnet.lua); without it Neovim falls back to a watcher
      # per directory. Also for scripts that wait on file changes.
      inotify-tools
      wl-clipboard # wl-copy: Neovim's clipboard, gh, rofimoji (WSL through WSLg)
    ];
}
