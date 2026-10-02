# Angular language server (ngserver): templates and Angular-specific checks,
# alongside vtsls for TypeScript. It prefers the project's own
# @angular/language-service from node_modules.
{ pkgs }:
{
  requires = [ "typescript" ];
  packages = [ pkgs.angular-language-server ];
}
