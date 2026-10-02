-- Containers (container toolchain; any engine, Podman included): Dockerfile and
-- Compose language servers, and hadolint.
---@type Toolchain
return {
  -- Compose files: the Compose language server only attaches to the
  -- yaml.docker-compose filetype, while Neovim detects them as yaml. The yaml
  -- part keeps treesitter and other YAML tooling working. (process-compose.yaml
  -- belongs to a different tool and stays yaml.)
  filetype = {
    pattern = {
      ["compose%.ya?ml"] = "yaml.docker-compose",
      ["compose%..+%.ya?ml"] = "yaml.docker-compose",
      ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
      ["docker%-compose%..+%.ya?ml"] = "yaml.docker-compose",
    },
  },
  servers = {
    dockerls = {},
    docker_compose_language_service = {},
  },
  linters_by_ft = { dockerfile = { "hadolint" } },
  lint_roots = { hadolint = { ".hadolint.yaml", ".hadolint.yml" } },
}
