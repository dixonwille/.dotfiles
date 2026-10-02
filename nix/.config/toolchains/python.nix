# Python: uv (package manager and runner), ruff (lint and format) and ty (type
# checker), with servers for both. Unversioned, like dotnet: uv provides the
# Python a project asks for (.python-version, requires-python), installing it
# on demand. uv's own builds work with prebuilt wheels, unlike nixpkgs' Python
# outside NixOS (no system library paths, so no libstdc++).
{ pkgs }:
{
  packages = [
    pkgs.uv
    pkgs.ruff
    pkgs.ty
  ];
  # Only uv's own Python builds, never the OS's, so every machine runs the
  # same interpreters
  env.UV_PYTHON_PREFERENCE = "only-managed";
}
