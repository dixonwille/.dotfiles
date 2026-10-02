# Go 1.26 (nixpkgs' latest patch release) and gopls. Add a go1_<minor>.nix for
# another minor version.
{ pkgs }:
{
  packages = [
    pkgs.go_1_26
    pkgs.gopls
  ];
  # Always use this Go, even when a go.mod asks for a newer one, instead of
  # downloading that toolchain
  env.GOTOOLCHAIN = "local";
}
