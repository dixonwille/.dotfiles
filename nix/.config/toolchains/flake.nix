{
  description = "Composable development toolchains, loaded with direnv's `use toolchain <name>...`";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # Every <name>.nix next to this file (except flake.nix) is a toolchain:
      #   { pkgs }: { packages = [ ... ]; env = { NAME = "value"; }; shellHook = "..."; }
      # All three fields are optional.
      names = map (lib.removeSuffix ".nix") (builtins.filter
        (f: f != "flake.nix" && lib.hasSuffix ".nix" f)
        (builtins.attrNames (builtins.readDir ./.)));

      # One shell from several toolchains. Merged here rather than with
      # mkShell's inputsFrom, which keeps packages and shellHooks but silently
      # drops `env` variables. A later toolchain's variables win.
      mkToolchainShell = pkgs: toolchains: pkgs.mkShell {
        packages = lib.concatMap (t: t.packages or [ ]) toolchains;
        env = lib.foldl' (env: t: env // (t.env or { })) { } toolchains;
        shellHook = lib.concatMapStringsSep "\n" (t: t.shellHook or "") toolchains;
      };
    in
    {
      devShells = forAllSystems (pkgs:
        let
          toolchains = lib.genAttrs names (name: import ./${name}.nix { inherit pkgs; });
          requested = builtins.filter (n: n != "")
            (lib.splitString " " (builtins.getEnv "DOTFILES_TOOLCHAIN"));
          pick = name: toolchains.${name} or (throw
            "unknown toolchain '${name}' (available: ${lib.concatStringsSep ", " names})");
        in
        # Each toolchain on its own (e.g. `nix develop ~/.config/toolchains#lua`)
        lib.mapAttrs (_: t: mkToolchainShell pkgs [ t ]) toolchains // {
          # The toolchains named in $DOTFILES_TOOLCHAIN, in order, as one shell.
          # Reading the variable requires --impure (see use_toolchain in direnvrc).
          default = mkToolchainShell pkgs (map pick requested);
        });
    };
}
