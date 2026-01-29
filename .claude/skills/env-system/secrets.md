# Secret Management with 1Password

Secrets are managed via 1Password CLI with a caching layer to avoid repeated authentication prompts.

## The _cache_op_secret() Function

```bash
_cache_op_secret "op://vault/item/field" "CACHE_NAME" ["account"]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `op://...` | Yes | 1Password secret reference |
| `CACHE_NAME` | Yes | Unique name for cache file |
| `account` | No | 1Password account (default: `my.1password.com`) |

### Cache Details

- **Location**: `~/.cache/zsh/op-secrets/`
- **TTL**: 30 days
- **Format**: Plain text files named by CACHE_NAME

## Usage Pattern

```bash
# In env.d file (e.g., personal/zsh-work/.config/zsh/env.d/40-secrets.zsh)

# Basic usage
export GITHUB_TOKEN="$(_cache_op_secret "op://Development/GitHub/token" "GITHUB_TOKEN")"

# With specific account
export WORK_API_KEY="$(_cache_op_secret "op://Work/API/key" "WORK_API_KEY" "company.1password.com")"
```

## Finding 1Password References

```bash
# List vaults
op vault list

# List items in vault
op item list --vault "Development"

# Get item details (shows field names)
op item get "GitHub" --vault "Development"
```

## Troubleshooting

```bash
# Clear cache to force refresh
rm ~/.cache/zsh/op-secrets/TOKEN_NAME

# Test secret retrieval directly
op read "op://vault/item/field"

# Check if signed in
op account list
```
