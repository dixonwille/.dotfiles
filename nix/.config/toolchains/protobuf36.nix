# Protocol Buffers 36 (protoc), the Go code generators (protoc-gen-go,
# protoc-gen-go-grpc), and the protols language server. Generated code records
# the generator versions; protoc follows this toolchain's version, while the
# Go plugins have a single nixpkgs version and move with flake.lock updates.
{ pkgs }:
{
  packages = [
    pkgs.protobuf_36
    pkgs.protoc-gen-go
    pkgs.protoc-gen-go-grpc
    pkgs.protols
  ];
}
