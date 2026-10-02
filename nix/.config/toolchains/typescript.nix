# TypeScript and JavaScript language server (vtsls), plus the servers from
# vscode-langservers-extracted: ESLint (using the project's own eslint), HTML,
# CSS/SCSS/Less, and JSON. Formatting is prettierd, a prettier daemon running
# the project's own prettier.
{ pkgs }:
{
  packages = [
    pkgs.vtsls
    pkgs.vscode-langservers-extracted
    pkgs.prettierd
  ];
  # Never fall back to prettierd's bundled prettier, whose version and defaults
  # may not match the project's
  env.PRETTIERD_LOCAL_PRETTIER_ONLY = "1";
}
