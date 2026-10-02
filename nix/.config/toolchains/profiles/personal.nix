# Personal machine tools, added to the nix profile beside global.nix
# (install/desktop, install/framework, install/macmini). Must not share a
# package with another set installed on the same machine.
{ pkgs }:
pkgs.buildEnv {
  name = "dotfiles-personal";
  paths = with pkgs; [
    typst
    codecrafters-cli
  ];
}
