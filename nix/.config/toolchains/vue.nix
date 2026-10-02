# Vue language server. It handles templates and styles, and leaves <script> to
# vtsls with Vue's TypeScript plugin, which VUE_TYPESCRIPT_PLUGIN points at.
{ pkgs }:
{
  requires = [ "typescript" ];
  packages = [ pkgs.vue-language-server ];
  # The directory tsserver resolves @vue/typescript-plugin from (same version
  # as the language server)
  env.VUE_TYPESCRIPT_PLUGIN = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";
}
