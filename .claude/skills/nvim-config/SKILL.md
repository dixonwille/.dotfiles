---
name: nvim-config
description: Neovim Lua configuration patterns. Use when modifying editor settings, plugins, or language configurations.
user-invocable: false
---

# Neovim Configuration

Lua-based configuration for Neovim nightly (v0.12+).

## File Structure

```
nvim/.config/nvim/
├── init.lua           # Entry point, core settings, keymaps
└── lua/
    ├── packages.lua   # Plugin management (vim.pack)
    ├── ui.lua         # UI configuration (theme, icons, ui2 messages)
    ├── statusline.lua # Custom statusline (mini.statusline style, standard hl groups)
    ├── navigation.lua # File navigation (fzf, oil)
    ├── treesitter.lua # Parser auto-install (filetype + injected languages in view)
    ├── languages.lua  # LSP, formatting, linting
    └── completion.lua # blink.cmp setup (and why not built-in completion)
```

## Module Loading

`init.lua` uses `safe_require()` to load modules gracefully:
```lua
require("packages")      -- Must succeed (installs plugins)
safe_require("ui")       -- Continues if fails
safe_require("navigation")
safe_require("treesitter")
safe_require("languages")
safe_require("completion")
```

## Plugin Management

Uses Neovim's built-in `vim.pack` API (v0.12+):

```lua
vim.pack.add({
  { src = "https://github.com/user/plugin" },
  { src = "https://github.com/user/plugin", version = "main" },
  { src = "https://github.com/user/plugin", version = vim.version.range('^1') },
})
```

Update plugins: `:PackUpdate`
Match lock file versions: `:PackLock`

## Key Settings

- Leader: `<Space>`
- Line numbers: Relative
- Tabs: 2 spaces
- Color column: 80
- Undo: Persistent (`undofile`)

## Reference

See `plugins.md` for complete plugin list and vim.pack API details.
