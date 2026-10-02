{
  description = "Composable development toolchains, loaded with direnv's `use toolchain <name>...`";

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
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # Every <name>.nix next to this file (except flake.nix) is a toolchain:
      #   { pkgs }: {
      #     packages = [ ... ]; env = { NAME = "value"; }; shellHook = "...";
      #     requires = [ "<toolchain>" ];  # loaded with it, once, before it
      #   }
      # All fields are optional.
      names = map (lib.removeSuffix ".nix") (
        builtins.filter (f: f != "flake.nix" && lib.hasSuffix ".nix" f) (
          builtins.attrNames (builtins.readDir ./.)
        )
      );

      # One shell from several toolchains. Merged here rather than with
      # mkShell's inputsFrom, which keeps packages and shellHooks but silently
      # drops `env` variables. A later toolchain's variables win.
      mkToolchainShell =
        pkgs: toolchains:
        pkgs.mkShell {
          packages = lib.concatMap (t: t.packages or [ ]) toolchains;
          env = lib.foldl' (env: t: env // (t.env or { })) { } toolchains;
          shellHook = lib.concatMapStringsSep "\n" (t: t.shellHook or "") toolchains;
        };
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          toolchains = lib.genAttrs names (name: import ./${name}.nix { inherit pkgs; });
          requested = builtins.filter (n: n != "") (
            lib.splitString " " (builtins.getEnv "DOTFILES_TOOLCHAIN")
          );
          pick =
            name:
            toolchains.${name}
              or (throw "unknown toolchain '${name}' (available: ${lib.concatStringsSep ", " names})");
          # The named toolchains, each preceded by the ones it requires, once each
          withRequired =
            names:
            lib.unique (lib.concatMap (name: withRequired ((pick name).requires or [ ]) ++ [ name ]) names);
          shellOf = names: mkToolchainShell pkgs (map pick (withRequired names));
        in
        # Each toolchain on its own (e.g. `nix develop ~/.config/toolchains#lua`)
        lib.mapAttrs (name: _: shellOf [ name ]) toolchains
        // {
          # The toolchains named in $DOTFILES_TOOLCHAIN, in order, as one shell.
          # Reading the variable requires --impure (see use_toolchain in direnvrc).
          default = shellOf requested;
        }
      );

      # Package sets for the user's nix profile, rather than a project: every
      # profiles/<name>.nix (e.g. `nix profile add path:...#global`).
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # Unfree packages the sets may use, by name
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "claude-code"
                "1password-cli"
                "terraform"
              ];
          };
          profiles = map (lib.removeSuffix ".nix") (
            builtins.filter (lib.hasSuffix ".nix") (builtins.attrNames (builtins.readDir ./profiles))
          );
        in
        lib.genAttrs profiles (name: import ./profiles/${name}.nix { inherit pkgs; })
      );
    };
}
