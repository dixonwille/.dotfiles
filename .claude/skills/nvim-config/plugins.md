# Neovim Plugins Reference

## vim.pack API

Neovim 0.12+ built-in plugin manager.

### Adding Plugins

```lua
vim.pack.add({
  { src = "https://github.com/user/repo" },
  { src = "https://github.com/user/repo", version = "main" },
  { src = "https://github.com/user/repo", version = vim.version.range('^1') },
})
```

### Updating Plugins to latest

```vim
:PackUpdate
```

### Updating Plugins to match lock file

```vim
:PackLock
```

### Pack Event Handlers

Handle post-install/update actions:

```lua
add_pack_handler("update", "plugin-name", function()
  -- Run after plugin updates
end)

add_pack_handler({ "update", "install" }, "plugin-name", function()
  -- Run after install or update
end)
```

## Current Plugins

| Plugin | Purpose |
|--------|---------|
| nvim-treesitter | Syntax highlighting and parsing |
| nvim-lspconfig | LSP server configurations |
| conform.nvim | Formatting |
| nvim-lint | Linting |
| fzf-lua | Fuzzy finder UI |
| oil.nvim | File navigation as buffer |
| vague.nvim | Color scheme |
| mini.icons | Icons (statusline, fzf-lua, oil); standalone, no other mini modules |
| blink.cmp (v1) | Completion menu, docs and signature help windows; no snippet source |

## Language Tooling

Language servers, formatters, and linters are NOT installed by Neovim (no mason).
They come from the project environment, and Neovim uses whatever is on `PATH`
when it starts:

- A repo's `.envrc` loads toolchains: `use toolchain lua` (see the `nix` package,
  `~/.config/toolchains/`). Repos with their own flake use `use flake` instead.
- `languages.lua` applies one rule to all three: a tool is used only if its
  command is executable.
  - LSP: `enable_available({ ... })`. Use nvim-lspconfig defaults, no overrides.
  - conform: `formatters_by_ft`; missing formatters are skipped quietly and LSP
    formatting is the fallback.
  - nvim-lint: `linters_by_ft`; missing linters are skipped. Linters that only
    read config from their working directory go in `lint_roots`.
- Tool settings belong in the project's own config files, not in Neovim
  (e.g. `.luarc.json`, `.stylua.toml`, `selene.toml` in the nvim config dir).

Languages are reintroduced one at a time as they are needed.
