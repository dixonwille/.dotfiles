# Lua language server, formatter, and linter. Projects describe their libraries
# in .luarc.json, formatting in .stylua.toml, and lints in selene.toml.
{ pkgs }:
{
  packages = [
    pkgs.lua-language-server
    pkgs.stylua
    pkgs.selene
  ];
}
