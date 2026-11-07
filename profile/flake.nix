{
  description = "Command-line tools for the nix profile: what every machine needs, whatever the project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      # One set per <name>.nix next to this file (today just global:
      # `nix profile add path:...#global`).
      # Project tools (runtimes, language servers, linters) aren't here: they come from
      # each project's mise.toml, or on work from the workstation.
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # Unfree packages the sets may use, by name
            config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];
          };
          sets = map (lib.removeSuffix ".nix") (
            builtins.filter (f: f != "flake.nix" && lib.hasSuffix ".nix" f) (
              builtins.attrNames (builtins.readDir ./.)
            )
          );
        in
        lib.genAttrs sets (name: import ./${name}.nix { inherit pkgs; })
      );
    };
}
