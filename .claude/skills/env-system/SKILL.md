---
name: env-system
description: Environment variable configuration system. Use when adding environment variables, managing secrets with 1Password, or working with env.d files.
user-invocable: false
---

# Environment Configuration System

Two places, by what a variable needs:

- **Plain values** go in `~/.config/environment.d/*.conf`, systemd's format
  (`KEY=VALUE`, `$VAR`/`${VAR:-default}` expansion only, `#` comments), the
  same as the work workstation's `env file`. The systemd user manager
  reads them itself; `.zshenv` sources them (`set -a`) for shells it didn't
  start (WSL terminals, macOS). So no spaces or quotes in values: lists use
  `:`. The directory stays real (stow `--no-folding`): the workstation writes
  its env file there.
- **Anything needing shell code** (PATH dedupe, `mkdir`, functions, 1Password
  secrets) goes in zsh's modular `env.d`, numbered files controlling load order.

## Locations

| Location | Purpose |
|----------|---------|
| `personal/work/.config/environment.d/` | Work's plain values (private submodule), e.g. `60-dotfiles-work.conf` |
| `home/.config/zsh/env.d/` | Shell code, all machines |

## File Naming Convention

Files are numbered to control load order:
```
10-paths.zsh      # Loaded first
20-tmpdir.zsh     # Loaded second
30-tools.zsh      # Loaded third
```

Lower numbers load first. Use gaps (10, 20, 30) to allow insertion.

## Adding Environment Variables

1. A plain value: a `.conf` in an `environment.d` package (after `50-`, the
   workstation's), then `systemctl --user daemon-reload` for systemd's copy
2. Shell code: a numbered file in zsh's `env.d`, with an export statement

```bash
# In env.d/30-tools.zsh
export MY_TOOL_HOME="/path/to/tool"
```

## Secret Management

Uses 1Password CLI with caching. See `secrets.md` for the `_cache_op_secret()` function and patterns.

## Best Practices

- Keep related variables in same file
- Use descriptive file names after the number
- Document non-obvious variables with comments
- Secrets go in work env.d (private submodule)
