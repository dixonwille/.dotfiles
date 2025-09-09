export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Load zstat module if not already loaded
zmodload zsh/stat 2>/dev/null

# 1Password secret caching function
_cache_op_secret() {
  local op_ref="$1"
  local var_name="$2"
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/op-secrets"
  local cache_file="$cache_dir/$var_name"
  local ttl_days=30
  
  # Create cache directory with secure permissions
  if [ ! -d "$cache_dir" ]; then
    mkdir -p "$cache_dir"
    chmod 700 "$cache_dir"
  fi
  
  # Check if cache exists and is valid
  if [ -f "$cache_file" ]; then
    local file_mtime
    if file_mtime=$(zstat +mtime "$cache_file" 2>/dev/null); then
      local cache_age=$(( $(date +%s) - file_mtime ))
    else
      local cache_age=999999999  # Force refresh if we can't get mtime
    fi
    local ttl_seconds=$(( ttl_days * 24 * 60 * 60 ))
    
    if [ $cache_age -lt $ttl_seconds ]; then
      cat "$cache_file"
      return 0
    fi
  fi
  
  # Cache miss or expired - fetch from 1Password
  if command -v op >/dev/null 2>&1; then
    # Check if authenticated, sign in if needed
    if ! op whoami >/dev/null 2>&1; then
      echo "Signing in to 1Password to get updated secrets..." >&2
      if ! eval $(op signin); then
        # Sign-in failed, return cached value if available
        if [ -f "$cache_file" ]; then
          cat "$cache_file"
        fi
        return 1
      fi
    fi
    
    local secret_value
    if secret_value=$(op read "$op_ref" 2>/dev/null); then
      echo "$secret_value" > "$cache_file"
      chmod 600 "$cache_file"
      echo "$secret_value"
      return 0
    fi
  fi
  
  # Fallback: return cached value even if expired, or empty
  if [ -f "$cache_file" ]; then
    cat "$cache_file"
  fi
}

# Source environment files from main and module env.d directories
for env_dir in "$ZDOTDIR/env.d"; do
  if [ -d "$env_dir" ]; then
    for env_file in "$env_dir"/*.zsh; do
      if [ -r "$env_file" ]; then
        . "$env_file"
      fi
    done
  fi
done
