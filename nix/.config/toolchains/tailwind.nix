# Tailwind CSS language server (class completion, hover, colors, lints). It
# loads the project's own tailwindcss from node_modules, so v3 and v4 projects
# both work. Framework-independent: add it next to vue, angular, etc.
{ pkgs }:
{
  packages = [ pkgs.tailwindcss-language-server ];
}
