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
| `home/.zshenv` | Sets `ZDOTDIR`, loads `~/.config/environment.d/*.conf` (plain values), then `env.d/` |
| `home/.config/zsh/.zshrc` | Main configuration |
| `home/.config/zsh/env.d/` | Environment set up with shell code (PATH, functions, secrets) |
| `home/.config/zsh/rc.d/` | Interactive-only snippets (e.g. `osc7.zsh`, the terminals' cwd reporting) |
| `~/.config/zsh/.zshrc_work` | Work only, from `personal/work` |

## Key Features

- **XDG compliance**: All configs in `~/.config/zsh/`
- **Vi mode**: Enabled by default
- **History**: 10k entries, XDG-compliant location
- **Conditional loading**: Tools/plugins load only if available
- **mise**: `mise activate zsh` puts each project's tools (its `mise.toml`) on PATH while in it; PATH entries added after it (direnv's) stay ahead

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
keybinds, so it can rebind). It comes from `personal/work`, stowed only where the
work machine's own setup is installed, and runs the workstation's
its init (its env file, `~/.local/bin`, direnv's hook).

## Testing Changes

```bash
# Source updated config
source ~/.config/zsh/.zshrc

# Or start new shell
zsh
```

## Adding Aliases/Functions

Add to `.zshrc`. Environment variables: a plain value goes in an `environment.d` `.conf` (see the env-system skill), anything needing shell code in a numbered `env.d/` file.
