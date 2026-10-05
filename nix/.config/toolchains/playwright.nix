# Playwright's Chromium, built by Nix for the Playwright version the project
# locks, so each project keeps its own version. The browsers Playwright
# downloads itself run on the OS's glibc and libraries (Ubuntu lacks
# libnspr4 & co.); these run on Nix's, the same on every machine.
#
# Reads $DOTFILES_PLAYWRIGHT_LOCK (default package-lock.json, relative to the
# .envrc), which use_toolchain watches. The browsers come from
# playwright-web-flake, tagged per Playwright release; a release with no tag
# yet fails to fetch.
{ pkgs }:
let
  lockName =
    let
      name = builtins.getEnv "DOTFILES_PLAYWRIGHT_LOCK";
    in
    if name == "" then "package-lock.json" else name;
  lockPath = builtins.getEnv "PWD" + "/" + lockName;
  lock =
    if builtins.pathExists lockPath then
      builtins.fromJSON (builtins.readFile lockPath)
    else
      throw "playwright toolchain: no ${lockPath} (set DOTFILES_PLAYWRIGHT_LOCK in .envrc)";
  version =
    lock.packages."node_modules/playwright-core".version
      or (throw "playwright toolchain: ${lockPath} doesn't lock playwright-core");
  flake = builtins.getFlake "github:pietdevries94/playwright-web-flake/${version}";
  browsers = flake.packages.${pkgs.stdenv.hostPlatform.system}.playwright-driver.browsers.override {
    withFirefox = false;
    withWebkit = false;
  };
in
{
  env = {
    PLAYWRIGHT_BROWSERS_PATH = "${browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };
}
