# Node.js 24 and npm, the runtime a project builds and runs with. Language
# servers bring their own Node, so this is only for the project. Add another
# node<major>.nix when a project needs a different major version.
{ pkgs }:
{
  packages = [ pkgs.nodejs_24 ];
}
