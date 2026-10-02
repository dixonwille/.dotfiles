-- Shell scripts (shell toolchain; bash and sh, nothing supports zsh):
-- bash-language-server, with shellcheck for its diagnostics, and shfmt, which
-- follows the repository's .editorconfig.
---@type Toolchain
return {
  servers = { bashls = {} },
  formatters_by_ft = {
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
}
