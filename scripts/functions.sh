_df_modules=()
df_module() {
  _df_modules+=("$1")
}

_df_inherit=() 
df_inherit() {
  _df_inherit+=("$1")
}

_df_after_install=()
df_after_install() {
  _df_after_install+=("$1")
}

_df_before_install=()
df_before_install() {
  _df_before_install+=("$1")
}

declare -A _df_symlinks
df_symlink() {
	_df_symlinks[$1]="$2"
}

_df_copr=()
_df_packages=()
df_package() {
	if [[ "$1" == *"/"* ]]; then
		_df_copr+=("$1")
	else
		_df_packages+=("$1")
	fi
}

create_symlinks() {
  rm -f "$XDG_CONFIG_HOME/environment.d/"*
  rm -f "$XDG_CONFIG_HOME/alias.d/"*
  for src in "${!_df_symlinks[@]}"; do
    ln -sf "$src" "${_df_symlinks[$src]}"
  done
}

install_packages() {
  if [[ "${DFCONF[IS_FEDORA]}" == "1" ]];then
    sudo dnf update -y
    if [[ "${#_df_copr[@]}" -gt 0 ]];then
      sudo dnf install dnf-plugins-core -y
    fi
    for copr in "${_df_copr[@]}"; do
      sudo dnf copr enable "$copr" -y
    done
    sudo dnf install "${_df_packages[@]}" -y
  fi
}

after_install() {
  for cmd in "${_df_after_install[@]}"; do
    eval "$cmd"
  done
}

before_install() {
  for cmd in "${_df_before_install[@]}"; do
    eval "$cmd"
  done
}

load_inherit() {
  for inh in "${_df_inherit[@]}"; do
    source "$DOTFILESDIR/machines/$inh.sh"
  done
}

_df_env_idx=20
load_modules() {
  for module in "${_df_modules[@]}"; do
    load_module "$module"
  done
}

load_module() {
  local inc="0"
  if [[ -f "$DOTFILESDIR/modules/$1/environment" ]]; then
    df_symlink "$DOTFILESDIR/modules/$1/environment" "$XDG_CONFIG_HOME/environment.d/$_df_env_idx-$1"
    inc="1"
  fi
  if [[ -f "$DOTFILESDIR/modules/$1/alias" ]]; then
    df_symlink "$DOTFILESDIR/modules/$1/alias" "$XDG_CONFIG_HOME/alias.d/$_df_env_idx-$1"
    inc="1"
  fi
  source "$DOTFILESDIR/modules/$1/module.sh"
  if [[ -f "$DOTFILESDIR/modules/$1/out/environment" ]]; then
    df_symlink "$DOTFILESDIR/modules/$1/out/environment" "$XDG_CONFIG_HOME/environment.d/$_df_env_idx-$1"
    inc="1"
  fi
  if [[ "$inc" == "1" ]]; then
    _df_env_idx=$(($_df_env_idx + 1))
  fi
}

create_empty_file() {
  if [[ -f "$1" ]]; then
    chmod 0644 "$1"
    > "$1"
  else
    touch "$1"
  fi
}
