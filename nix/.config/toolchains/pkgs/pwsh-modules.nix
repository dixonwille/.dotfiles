# PowerShell modules from the PowerShell Gallery (none are in nixpkgs).
# pwsh-modules/modules.json lists the modules wanted and the Az release whose
# versions they take, so they work together; pwsh-modules/lock.json is
# generated from it by pwsh-modules/update.sh, with each package's hash as the
# Gallery publishes it, so there is no hash to maintain here.
#
# Modules go in share/powershell-modules/<Name>/<Version>, which PSModulePath
# names (not share/powershell/Modules: in a profile, that also holds
# PowerShell's own modules). They're read-only, so Install-Module and
# Update-Module can't change them; edit modules.json instead.
{ pkgs }:
let
  inherit (pkgs) lib;
  modules = lib.importJSON ./pwsh-modules/lock.json;

  install =
    module:
    let
      nupkg = pkgs.fetchurl {
        name = "${module.name}.${module.version}.nupkg";
        url = "https://www.powershellgallery.com/api/v2/package/${module.name}/${module.version}";
        inherit (module) hash;
      };
      # Named for the version without any prerelease suffix, as PowerShell expects
      version = lib.head (lib.splitString "-" module.version);
    in
    ''
      dir="$out/share/powershell-modules/${module.name}/${version}"
      mkdir -p "$dir"
      unzip -q ${nupkg} -d "$dir"
      # The NuGet packaging around the module
      rm -rf "$dir"/{'[Content_Types].xml',_rels,package,.signature.p7s,*.nuspec}
    '';
in
pkgs.runCommand "pwsh-modules" { nativeBuildInputs = [ pkgs.unzip ]; } (
  lib.concatMapStrings install modules
)
