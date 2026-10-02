# Shell scripts (bash and sh; nothing supports zsh): bash-language-server, with
# shellcheck for its diagnostics, and shfmt for formatting.
{ pkgs }:
{
  packages = [
    pkgs.bash-language-server
    pkgs.shellcheck
    pkgs.shfmt
  ];
}
