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
├── queries/           # Query extensions (; extends): gotmpl/ injections
├── spell/             # Shared spell word list (en.utf-8.add; compiled .spl ignored)
└── lua/
    ├── packages.lua   # Plugin management (vim.pack)
    ├── ui.lua         # UI configuration (theme, icons, ui2 messages)
    ├── statusline.lua # Custom statusline (mini.statusline style, standard hl groups)
    ├── navigation.lua # File navigation (fzf, oil)
    ├── treesitter.lua # Parser auto-install (filetype + injected languages in view)
    ├── toolchains.lua # Loads every toolchains/ module and applies their specs
    │                  # (servers, formatters, linters, filetypes, setup)
    ├── toolchains/    # One module per toolchain, returning a Toolchain spec
    │   ├── lua.lua, go.lua, protobuf.lua, shell.lua, nix.lua, bicep.lua,
    │   │   angular.lua, container.lua   # plain specs
    │   ├── dotnet.lua     # Roslyn: solution choice per file, :RoslynSolution
    │   ├── typescript.lua # vtsls, eslint, html, cssls, jsonls; prettierd
    │   ├── vue.lua        # vue_ls; vtsls gets the vue filetype and Vue's TS plugin
    │   ├── tailwind.lua   # tailwindcss; cssls learns Tailwind at-rules
    │   ├── python.lua     # ruff and ty from the project's .venv when present
    │   ├── powershell.lua # Editor Services from the toolchain, VS Code formatting
    │   ├── azure_pipelines.lua # Pipeline files (azure*.yml, DOTFILES_AZURE_PIPELINES)
    │   └── github_actions.lua  # Workflow filetype, actions-languageserver, actionlint
    ├── gotmpl.lua     # Go templates: filetype and rendered-language highlighting
    ├── completion.lua # blink.cmp setup (and why not built-in completion)
    └── spell.lua      # Spell checking (treesitter regions), word lists, z= picker
```

## Module Loading

`init.lua` uses `safe_require()` to load modules gracefully:
```lua
require("packages")      -- Must succeed (installs plugins)
safe_require("ui")       -- Continues if fails
safe_require("navigation")
safe_require("treesitter")
safe_require("toolchains")
safe_require("gotmpl")
safe_require("completion")
safe_require("spell")
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
