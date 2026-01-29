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
| plenary.nvim | Utility functions for other plugins |
| nvim-treesitter | Syntax highlighting and parsing |
| nvim-lspconfig | LSP server configurations |
| mason.nvim | LSP/formatter/linter installer |
| conform.nvim | Formatting |
| nvim-lint | Linting |
| fzf-lua | Fuzzy finder UI |
| oil.nvim | File navigation as buffer |
| vague.nvim | Color scheme |
| mini.statusline | Status line |
| mini.notify | Notifications |
| mini.icons | Icon support |
| blink.cmp | Auto-completion |
| LuaSnip | Snippet engine |
| friendly-snippets | Snippet collection |

## Language-Specific Setup

Create files in `lua/languages/` for language-specific configs:

```lua
-- lua/languages/example.lua
vim.lsp.enable("example_ls")

require("lint").linters_by_ft.example = { "example_linter" }

require("conform").formatters_by_ft.example = { "example_fmt" }
```
DO NOT automatically require the language. These are for projects to require in
their `.nvim.lua` file.
