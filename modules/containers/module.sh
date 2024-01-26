[[ "${DFLOADED[CONTAINERS]}" == "1" ]] && return
DFLOADED[CONTAINERS]="1"

df_package "kubernetes-client"
if [[ "${DFCONF[IS_WSL]}" == "1" ]]; then
  df_package "podman-remote"

  mkdir -p "$XDG_CONFIG_HOME/kube"
  mkdir -p "$XDG_CONFIG_HOME/containers"

  df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/.kube/config" "$XDG_CONFIG_HOME/kube/config"
  df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/.config/containers/containers.conf" "$XDG_CONFIG_HOME/containers/containers.conf"
 
  aliasFile="$DOTFILESDIR/modules/containers/out/alias"
  mkdir -p "$(dirname "$aliasFile")"
  create_empty_file "$aliasFile"
  echo "alias podman='podman-remote'" >> "$aliasFile"
  chmod -w "$aliasFile"
else
  df_package "podman"
fi
