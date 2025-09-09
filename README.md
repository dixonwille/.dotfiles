# Dotfiles

## Tools

- curl
- wget
- tar
- c toolchain
    - gcc
    - make
- git
- stow
- ripgrep
- fd-find
- fzf
- tmux
- unzip
- neovim (nightly v0.12)
    - tree-sitter-cli
- claude-code
- claude-code-acp
- git-delta
- JetBrainsMono Nerd Font Mono
- eza (optional)
- batcat cli (optional)
- mise (optional)
- oh-my-posh (optional)
- jj (optional)
- uv and uvx (for MCP)
- 1Password CLI (optional, for secret management)

## Environment Configuration

### env.d System

This dotfiles setup uses a modular environment configuration system through `env.d` directories:

- `zsh/.config/zsh/env.d/` - Main environment files (all machines)
- `personal/zsh-work/.config/zsh/env.d/` - Work-specific environment files

### 1Password Secret Management

The `_cache_op_secret()` function provides secure caching of 1Password secrets with a 30-day TTL.

**Usage in env.d files:**
```bash
# Basic usage
export MY_SECRET="$(_cache_op_secret "op://vault/item/field" "MY_SECRET")"

# Examples
export GITHUB_TOKEN="$(_cache_op_secret "op://Private/GitHub Token/credential" "GITHUB_TOKEN")"
export API_KEY="$(_cache_op_secret "op://Work/API Keys/production" "API_KEY")"
```

**Features:**
- Automatic 1Password CLI authentication when needed
- Secure cache with 600 permissions (user read/write only)
- 30-day cache TTL to minimize CLI calls
- Graceful fallback to cached values if authentication fails
- Cache location: `~/.cache/zsh/op-secrets/`
