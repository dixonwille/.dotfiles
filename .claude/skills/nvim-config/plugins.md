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
  - Toolchains hold what a project builds with and what the editor needs for
    its languages. General CLI tools (az, pwsh, func, fzf, rg, …) stay
    installed globally, even when the editor uses them.
  - Toolchains are versioned (`node24`, `go1_26`, `protobuf36`) when the
    project can see the tool's version and nixpkgs carries version lines for
    it. Editor-only tooling (`typescript`, `vue`, `angular`) and tools with a
    single nixpkgs version (`bicep`, `lua`) aren't; `flake.lock` pins those.
  - .NET: `use toolchain dotnet` (every SDK in use combined into one `dotnet`,
    plus roslyn-ls and the Azure Artifacts credential provider for NuGet).
    Unversioned on purpose: global.json selects the SDK.
  - Bicep: `use toolchain bicep` (CLI and Bicep.LangServer), usually alongside
    another: `use toolchain dotnet bicep`.
  - JavaScript/TypeScript: `typescript` (vtsls, plus ESLint, HTML, CSS/SCSS/Less
    and JSON servers); `vue` and `angular` add their servers and `require`
    `typescript`. The project's Node is separate and versioned (`node24`), e.g.
    `use toolchain dotnet bicep node24 vue`. Language servers and prettierd
    bring their own Node; npm uses the project's. prettierd only runs the
    project's own prettier (node_modules), else LSP formatting is the fallback.
  - Shell: `shell` (bash-language-server with shellcheck diagnostics, shfmt).
    shfmt uses conform's defaults: the repo's `.editorconfig`, else the
    buffer's indentation. bash and sh only; nothing supports zsh.
  - Tailwind: `tailwind` (tailwindcss-language-server, using the project's own
    tailwindcss), next to `vue`/`angular`/etc. Where it's loaded, cssls learns
    Tailwind's at-rules from `toolchains/tailwind-css-data.json`.
  - Python: `python` (uv, ruff, ty). Unversioned, like dotnet: uv installs the
    Python a project asks for (`UV_PYTHON_PREFERENCE=only-managed`, never the
    OS's). ruff and ty run from the project's `.venv` when it has them
    (`toolchains/python.lua`), else the toolchain's. Formatting is ruff's server.
  - PowerShell: `powershell` (Editor Services with PSScriptAnalyzer, running in
    nixpkgs' PowerShell; the global pwsh stays for running scripts). Default
    analysis rules unless a repo has `PSScriptAnalyzerSettings.psd1`.
    Formatting settings are the VS Code extension's defaults (copied, with
    their source, in `toolchains/powershell.lua`), not the server's own.
    Az modules come from the work nix profile (`pkgs/pwsh-modules.nix`) on
    `PSModulePath`, which the server inherits, so Az cmdlets complete too.
  - Azure Pipelines: `azure-pipelines` (Microsoft's language server, the pinned
    public pipeline schema). Pipelines are `azure*.yml`/`azure*.yaml` plus
    globs in a project's `DOTFILES_AZURE_PIPELINES` (`.envrc`); they get the
    `yaml.azure-pipelines` filetype (`toolchains/azure_pipelines.lua`).
  - GitHub Actions: `github-actions` (GitHub's own `actions-languageserver`
    from @actions/languageserver, actionlint). Workflow files
    (`.github/workflows/*.y(a)ml`) get the `yaml.github-actions` filetype,
    which both key on. `toolchains/github_actions.lua` points
    gh_actions_ls at it instead of lttb's older wrapper, and passes it a token
    and repo metadata from the global `gh` CLI (fetched in the background before
    the server starts) so it validates `with:` inputs, secrets and variables.
  - General YAML gets treesitter highlighting only; no YAML language server.
  - Servers not in nixpkgs are packaged in `toolchains/pkgs/` from npm
    (`npm-server.nix`: a package.json pinning the version plus its lockfile).
  - Nix: `nix` (nixd, nixfmt, statix, deadnix; Nix itself is global). Used by
    this repo's own `.envrc`. For repos with a shared `.envrc` (e.g. their own
    flake), add it in their untracked `.envrc.local` where it's sourced.
  - Containers: `container` (Dockerfile and Compose language servers,
    hadolint). Engine-agnostic: none of them talk to Podman or Docker. Compose
    files get the `yaml.docker-compose` filetype (`toolchains/container.lua`).
  - Go: versioned by minor (`go1_26`: Go and gopls, with `GOTOOLCHAIN=local`
    so go.mod can't swap in a downloaded Go).
  - Protobuf: `protobuf36` (protoc 36, protoc-gen-go, protoc-gen-go-grpc,
    protols), e.g. `use toolchain go1_26 protobuf36`.
  - A toolchain's `requires = [ ... ]` loads other toolchains with it, once
    each, before it.
  - Node comes from toolchains only; mise is gone (no activation in `.zshrc`),
    so a repo's `.mise.toml` is ignored.
- Each toolchain's editor tooling is a module, `lua/toolchains/<toolchain>.lua`
  (named like the toolchain with `_` for `-`; versioned toolchains share one:
  `go1_26` -> `go.lua`), returning a `Toolchain` spec. `toolchains.lua` loads
  every module (auto-discovered), merges the specs and applies them. Editor
  support that isn't tied to a toolchain (`gotmpl.lua`, `spell.lua`) is a
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
    warning; the other toolchains keep working.
  - Use nvim-lspconfig defaults; only override what Neovim itself needs (e.g.
    roslyn_ls re-enables file-watching capabilities that Neovim turns off on
    Linux; it watches with `inotifywait`, from inotify-tools in the global nix
    profile on Linux) or what wires servers together (vtsls loading Vue's TypeScript
    plugin), never server preferences. The exception is settings a VS Code
    extension sends by default that the server's own defaults contradict
    (powershell_es formatting); copy them with a comment naming the source.
- Editor settings that differ by machine or project come from `DOTFILES_*`
  environment variables: machine-wide in zsh's `env.d` (work ones in
  `personal/zsh-work`), extended per project in `.envrc`. E.g.
  `DOTFILES_GOTMPL` lists the Go template files as `glob` or `glob=language`;
  nothing else is a Go template (see `lua/gotmpl.lua`).
  `DOTFILES_AZURE_PIPELINES` adds pipeline file globs, usually per project.
  `DOTFILES_SPELLFILE` names a machine's own spell word list (2zg), e.g.
  work names in `personal/nvim/spell/` (set in `personal/zsh-work` env.d).
- Files that need different tooling than the rest of their language get a
  compound filetype (`yaml.github-actions`, `yaml.azure-pipelines`,
  `yaml.docker-compose`): treesitter still uses the yaml parser, while servers
  and linters key on the full filetype.
- Tool settings belong in the project's own config files, not in Neovim
  (e.g. `.luarc.json`, `.stylua.toml`, `selene.toml` in the nvim config dir).

Languages are reintroduced one at a time as they are needed.
