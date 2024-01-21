[[ "${DFLOADED[MICROSOFT]}" == "1" ]] && return
DFLOADED[MICROSOFT]="1"

if [[ "${DFCONF[IS_FEDORA]}" == "1" ]]; then
  if [[ "$(sudo dnf repolist | grep "^packages-microsoft-com-prod\\s")" == "" ]]; then
    df_before_install "sudo dnf config-manager --add-repo https://packages.microsoft.com/config/rhel/9/prod.repo"
    df_before_install "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
  fi
fi
