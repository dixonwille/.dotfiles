-- Nix: nixd, nixfmt, and statix (anti-patterns) and deadnix
-- (unused code) for linting.
---@type Language
return {
  servers = { nixd = {} },
  formatters_by_ft = { nix = { "nixfmt" } },
  linters_by_ft = { nix = { "statix", "deadnix" } },
  lint_roots = { statix = { "statix.toml" } },
}
