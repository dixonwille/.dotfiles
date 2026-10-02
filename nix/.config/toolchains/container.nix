# Container files (Dockerfile/Containerfile and compose files), whichever
# engine builds them (Podman, Docker): the Dockerfile and Compose language
# servers, and hadolint for linting. None of them talk to a container engine.
{ pkgs }:
{
  packages = [
    pkgs.dockerfile-language-server
    pkgs.docker-compose-language-service
    pkgs.hadolint
  ];
}
