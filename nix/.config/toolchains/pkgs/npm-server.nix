# A language server published on npm but not packaged in nixpkgs. `src` is a
# directory in npm-server/ holding a package.json that depends on it (pinned
# version) and the package-lock.json npm generated for it. importNpmLock
# fetches every package by the lockfile's own integrity hashes, so there is no
# hash to maintain here.
# `package` is the npm package, `bin` the executable it provides.
#
# To update to the newest release, run npm-server/update.sh [<directory>...].
# For a specific version, change it in package.json, then in that directory run
#   npm install --package-lock-only --ignore-scripts
{
  pkgs,
  package,
  bin,
  src,
}:
let
  version = (pkgs.lib.importJSON (src + "/package.json")).dependencies.${package};
in
pkgs.buildNpmPackage {
  pname = bin;
  inherit version src;
  npmDeps = pkgs.importNpmLock { npmRoot = src; };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;
  dontNpmBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r node_modules $out/lib/
    ln -s $out/lib/node_modules/.bin/${bin} $out/bin/${bin}
    runHook postInstall
  '';
}
