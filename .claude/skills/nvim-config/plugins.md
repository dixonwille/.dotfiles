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

Language servers, formatters, and linters are NOT installed by Neovim (no
mason, which needs every server's build toolchain installed globally), and not
globally either: each project's CI may pin different tools. They come from the
project, and Neovim uses whatever is on `PATH` when it starts:

- mise: a project's `mise.toml` (and `mise.lock`) lists its runtimes, CI tools
  and editor tools, on PATH while in it (`mise activate` in `.zshrc`).
  `~/.config/mise/config.toml` (the `mise` package) holds settings only.
  - My projects commit `mise.toml`, so CI (`jdx/mise-action`) runs the same
    versions. In someone else's repo, `mise.local.toml` (globally git-ignored).
  - Work: the work machine's own setup's nix profile provides the runtimes (dotnet
    SDKs, go, node, pwsh with the Az modules, bicep with Bicep.LangServer, uv).
    `~/Projects/mise.toml` (`personal/work`) adds the editor tools for
    every clone under it (mise merges parent directories' configs) and never a
    runtime, which would shadow the team's. Servers build and run with the
    team's runtimes: gopls (`go:` backend) with its go, Roslyn
    (`dotnet:roslyn-language-server`, prerelease, experimental backend) with its
    SDK, npm servers with its node.
  - A server needing more than a command: Editor Services is a module bundle
    (`powershell.lua` asks `mise where github:PowerShell/PowerShellEditorServices`);
    Vue's TypeScript plugin is found from the `vue-language-server` on PATH
    (`vue.lua`); the pipeline schema is a pinned URL (`azure_pipelines.lua`).
  - Repos with their own flake (`use flake` in a committed `.envrc`) still use
    direnv (hooked by the workstation's its init); its PATH entries stay
    ahead of mise's.
  - This repo's `mise.toml` has the Lua and shell tools. Nix tooling (nixd,
    nixfmt, statix, deadnix) has no release binaries: run nvim under
    `nix shell nixpkgs#nixd nixpkgs#nixfmt` for `profile/`.
- Per language:
  - .NET: Roslyn (`roslyn_ls`; nvim-lspconfig runs `roslyn-language-server`,
    the .NET tool's command, when `Microsoft.CodeAnalysis.LanguageServer` isn't
    on PATH). global.json selects the SDK.
  - Bicep: Bicep.LangServer, from the bicep CLI's own package.
  - JavaScript/TypeScript: vtsls, plus ESLint, HTML, CSS/SCSS/Less and JSON
    servers (vscode-langservers-extracted); vue and angular add their servers.
    prettierd only runs the project's own prettier (node_modules,
    `PRETTIERD_LOCAL_PRETTIER_ONLY` in conform's env for it), else LSP
    formatting is the fallback.
  - Shell: bash-language-server with shellcheck diagnostics, shfmt. shfmt uses
    conform's defaults: the repo's `.editorconfig`, else the buffer's
    indentation. bash and sh only; nothing supports zsh.
  - Tailwind: tailwindcss-language-server (using the project's own
    tailwindcss). Where it's on PATH, cssls learns Tailwind's at-rules from
    `languages/tailwind-css-data.json`.
  - Python: ruff and ty run from the project's `.venv` when it has them
    (`languages/python.lua`), else PATH's. Formatting is ruff's server.
  - PowerShell: Editor Services with PSScriptAnalyzer, in the `pwsh` on PATH
    (nvim-lspconfig's default). Default analysis rules unless a repo has
    `PSScriptAnalyzerSettings.psd1`. Formatting settings are the VS Code
    extension's defaults (copied, with their source, in
    `languages/powershell.lua`), not the server's own.
  - Azure Pipelines: Microsoft's language server, validating against the pinned
    public pipeline schema. Pipelines are `azure*.yml`/`azure*.yaml` plus globs
    in `DOTFILES_AZURE_PIPELINES`; they get the `yaml.azure-pipelines`
    filetype (`languages/azure_pipelines.lua`).
  - GitHub Actions: GitHub's own `actions-languageserver` (npm
    @actions/languageserver), actionlint. Workflow files
    (`.github/workflows/*.y(a)ml`) get the `yaml.github-actions` filetype,
    which both key on. `languages/github_actions.lua` points
    gh_actions_ls at it instead of lttb's older wrapper, and passes it a token
    and repo metadata from the global `gh` CLI (fetched in the background before
    the server starts) so it validates `with:` inputs, secrets and variables.
  - General YAML gets treesitter highlighting only; no YAML language server.
  - Nix: nixd, nixfmt, statix, deadnix.
  - Containers: Dockerfile and Compose language servers, hadolint.
    Engine-agnostic: none of them talk to Podman or Docker. Compose files get
    the `yaml.docker-compose` filetype (`languages/container.lua`).
  - Go: gopls (also formats).
  - Protobuf: protols.
- Each language's editor tooling is a module, `lua/languages/<language>.lua`
  (`_` for `-`), returning a `Language` spec. `languages.lua` loads
  every module (auto-discovered), merges the specs and applies them. Editor
  support that isn't tied to a language's tools (`gotmpl.lua`, `spell.lua`) is a
  top-level module instead. A spec has `servers` (name -> vim.lsp.config
  overrides, `{}` for defaults, plus `executable` when nvim-lspconfig's `cmd`
  is a function), `formatters_by_ft`/`formatters` (conform),
  `linters_by_ft`/`lint_roots` (nvim-lint; `lint_roots` for linters that only
  read config from their working directory), `filetype` (vim.filetype.add) and
  `setup` (anything else: commands, autocmds, query directives).
  - One rule for all tools: used only if its command is executable (servers
    enabled, linters run, missing formatters skipped quietly with LSP
    formatting as the fallback).
  - Modules may add to the same server (vue and tailwind add to typescript's
    vtsls and cssls) but never set the same setting: that warns at startup,
    naming both modules, and the first alphabetically keeps it. Linters for a
    filetype just add up. If a module needs to change what another set, give
    that server its own module instead.
  - Modules are all loaded before anything is applied, so reading
    `vim.lsp.config.<server>` in a module gives nvim-lspconfig's defaults.
  - A module that fails to load (or whose `setup` fails) is skipped with a
    warning; the other languages keep working.
  - Use nvim-lspconfig defaults; only override what Neovim itself needs (e.g.
    roslyn_ls re-enables file-watching capabilities that Neovim turns off on
    Linux; it watches with `inotifywait`, from inotify-tools in the global nix
    profile on Linux) or what wires servers together (vtsls loading Vue's TypeScript
    plugin), never server preferences. The exception is settings a VS Code
    extension sends by default that the server's own defaults contradict
    (powershell_es formatting); copy them with a comment naming the source.
- Editor settings that differ by machine come from `DOTFILES_*` environment
  variables in `~/.config/environment.d/*.conf` (work's in
  `personal/work`); lists are `:`-separated. E.g.
  `DOTFILES_GOTMPL` lists the Go template files as `glob` or `glob=language`;
  nothing else is a Go template (see `lua/gotmpl.lua`).
  `DOTFILES_AZURE_PIPELINES` adds pipeline file globs (a work repo's, in work's `environment.d`).
  `DOTFILES_SPELLFILE` names a machine's own spell word list (2zg), e.g.
  work names in `personal/nvim/spell/` (set in `personal/work`).
- Files that need different tooling than the rest of their language get a
  compound filetype (`yaml.github-actions`, `yaml.azure-pipelines`,
  `yaml.docker-compose`): treesitter still uses the yaml parser, while servers
  and linters key on the full filetype.
- Tool settings belong in the project's own config files, not in Neovim
  (e.g. `.luarc.json`, `.stylua.toml`, `selene.toml` in the nvim config dir).

Languages are reintroduced one at a time as they are needed.
