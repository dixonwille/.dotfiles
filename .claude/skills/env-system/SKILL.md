---
name: env-system
description: Environment variable configuration system. Use when adding environment variables, managing secrets with 1Password, or working with env.d files.
user-invocable: false
---

# Environment Configuration System

Modular `env.d` system for environment variables with numbered files controlling load order.

## Locations

| Location | Purpose |
|----------|---------|
| `zsh/.config/zsh/env.d/` | Main env files (all machines) |
| `personal/zsh-work/.config/zsh/env.d/` | Work-specific (private submodule) |

## File Naming Convention

Files are numbered to control load order:
```
10-paths.zsh      # Loaded first
20-tmpdir.zsh     # Loaded second
30-tools.zsh      # Loaded third
```

Lower numbers load first. Use gaps (10, 20, 30) to allow insertion.

## Adding Environment Variables

1. Identify appropriate env.d directory (main vs work)
2. Choose file by category or create new numbered file
3. Add export statement

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
