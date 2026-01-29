---
name: bash
description: Bash scripting conventions and patterns. Loaded automatically when working with bash scripts.
user-invocable: false
---

# Bash Conventions

These are the required conventions for bash scripts.

## Directory Navigation
- NEVER use `cd` - always use `pushd/popd`
- Use absolute paths when possible

## Script Directory Pattern
```bash
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
```

## Data Storage
- `${XDG_CACHE_HOME:-$HOME/.cache}` for cache
- `${XDG_DATA_HOME:-$HOME/.local/share}` for data
- Never hardcode paths in $HOME

## Error Handling
- `set -euo pipefail` at top
- Validation errors: collect ALL, report at end
- Runtime errors: continue as far as possible, report at end

## Subshell Awareness
Variables in subshells don't propagate. Use:
```bash
while read -r line; do
  # variables available after loop
done < <(command)
```

## Quoting
- Always quote: `"$var"` not `$var`
- Defaults: `"${var:-default}"`

## Validation Checks
1. `set -e` incompatibilities
2. Subshell variable scope
3. Unquoted variables
4. Missing error handling
5. `cd` instead of `pushd/popd`
6. Hardcoded paths vs XDG
