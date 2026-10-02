# Nix language tooling (Nix itself is installed globally): nixd language server,
# nixfmt (the official formatter), and statix (anti-patterns) and deadnix
# (unused code) for linting.
{ pkgs }:
{
  packages = [
    pkgs.nixd
    pkgs.nixfmt
    pkgs.statix
    pkgs.deadnix
  ];
}
