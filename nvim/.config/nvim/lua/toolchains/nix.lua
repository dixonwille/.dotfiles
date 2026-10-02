-- Nix (nix toolchain): nixd, nixfmt, and statix (anti-patterns) and deadnix
-- (unused code) for linting.
---@type Toolchain
return {
  servers = { nixd = {} },
  formatters_by_ft = { nix = { "nixfmt" } },
  linters_by_ft = { nix = { "statix", "deadnix" } },
  lint_roots = { statix = { "statix.toml" } },
}
