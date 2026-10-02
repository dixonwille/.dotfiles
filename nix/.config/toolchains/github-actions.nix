# GitHub Actions workflows: GitHub's own language server (@actions/languageserver;
# not in nixpkgs, packaged from pkgs/actions-languageserver) for completion,
# hover and validation, and actionlint for linting (including shellcheck on
# run: scripts).
{ pkgs }:
{
  packages = [
    (import ./pkgs/npm-server.nix {
      inherit pkgs;
      package = "@actions/languageserver";
      bin = "actions-languageserver";
      src = ./pkgs/actions-languageserver;
    })
    pkgs.actionlint
  ];
}
