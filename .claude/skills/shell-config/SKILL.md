---
name: shell-config
description: Zsh shell configuration. Use when modifying shell settings, plugins, or work integration.
user-invocable: false
---

# Shell Configuration

Zsh configuration following XDG Base Directory specification.

## File Locations

| File | Purpose |
|------|---------|
| `home/.zshenv` | Sets `ZDOTDIR`, keeps PATH entries unique, loads `~/.config/environment.d/*.conf` |
| `home/.config/zsh/.zshrc` | Main configuration |
| `home/.config/zsh/rc.d/` | Interactive-only snippets (e.g. `osc7.zsh`, the terminals' cwd reporting) |
| `~/.config/zsh/.zshrc_work` | Work only, from `personal/work` |

## Key Features

- **XDG compliance**: All configs in `~/.config/zsh/`
- **Vi mode**: Enabled by default
- **History**: 10k entries, XDG-compliant location
- **Conditional loading**: Tools/plugins load only if available
- **Order** (`.zshrc`'s sections): options and history, completion (`compinit`), `rc.d/`, widgets and keybinds, `.zshrc_work` (after keybinds, so it can rebind; on work it hooks direnv), mise (after it, see below), prompt, completions needing `compdef`, aliases, and the plugins last (zsh-syntax-highlighting wraps every widget defined before it)
- **direnv**: not installed by the dotfiles; only where a machine's own setup brings and hooks it (the work overrides)
- **mise**: each project's tools, from its `mise.toml`. mise and direnv: mise doesn't support running beside direnv (both rewrite PATH at each prompt). Where a machine's own setup hooks direnv (from `.zshrc_work`), `.zshrc` sets mise up after it: with direnv hooked, mise's shims go last on PATH (no prompt hook; each shim resolves its version from the directory it runs in, `[env]` isn't applied), so direnv's and the machine's own tools come first; elsewhere, `mise activate zsh`. Tested: in a repo with both an `.envrc` and a `mise.toml`, direnv's tool wins; in a mise-only repo, mise's. Outside any configured project a shim fails with "No version is set for shim" (in both modes: `mise activate` keeps the shims on PATH too, `activate_shims`); Neovim swaps the shims for the project's real tool directories at startup (`lua/mise.lua`)

## Plugins

Managed via git submodules in `home/.local/share/zsh/plugins/`:

| Plugin | Purpose |
|--------|---------|
| zsh-autosuggestions | Fish-like autosuggestions |
| zsh-syntax-highlighting | Command syntax highlighting |

## Prompt

Uses oh-my-posh (optional). Config in `home/.config/oh-my-posh/`.

## Work Integration

If `~/.config/zsh/.zshrc_work` exists, it's sourced automatically (after the
keybinds, so it can rebind). It comes from the private submodule's work layer,
stowed only where `personal/install` decides.

## Testing Changes

```bash
# Source updated config
source ~/.config/zsh/.zshrc

# Or start new shell
zsh
```

## Adding Aliases/Functions

Add to `.zshrc`. Environment variables (PATH included) go in an `environment.d` `.conf` (see the env-system skill).
